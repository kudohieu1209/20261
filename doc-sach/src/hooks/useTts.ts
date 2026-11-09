import { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import {
  getStoredTtsSettings,
  saveStoredTtsSettings,
  splitSentences,
  type Sentence,
} from '../lib/tts'

export interface UseTtsReader {
  paragraphs: { start: number; text: string }[]
  isLastChapter: boolean
  nextChapter: () => void
}

export interface UseTtsPaginator {
  pageRange: { start: number; end: number }
  goToOffset: (offset: number) => void
}

export function useTts(reader: UseTtsReader, paginator: UseTtsPaginator) {
  const supported = typeof window !== 'undefined' && 'speechSynthesis' in window

  const [voices, setVoices] = useState<SpeechSynthesisVoice[]>([])
  const [voice, setVoiceState] = useState<SpeechSynthesisVoice | null>(null)
  const [rate, setRateState] = useState(() => getStoredTtsSettings().rate)
  const [playing, setPlaying] = useState(false)
  const [current, setCurrent] = useState<Sentence | null>(null)

  const isPlayingRef = useRef(false)
  const sentenceIndexRef = useRef(0)
  const pendingNextChapterRef = useRef(false)
  const voiceRef = useRef<SpeechSynthesisVoice | null>(null)
  const rateRef = useRef(rate)

  // Danh sách các câu của chương hiện tại
  const sentences = useMemo(() => {
    return splitSentences(reader.paragraphs)
  }, [reader.paragraphs])

  const sentencesRef = useRef<Sentence[]>([])

  useEffect(() => {
    voiceRef.current = voice
    rateRef.current = rate
    sentencesRef.current = sentences
  }, [voice, rate, sentences])

  // 1. Khởi tạo danh sách giọng đọc và thiết lập đã lưu
  useEffect(() => {
    if (!supported) return

    const initialSettings = getStoredTtsSettings()

    const updateVoices = () => {
      const allVoices = window.speechSynthesis.getVoices()
      // Lọc ưu tiên giọng tiếng Việt
      const viVoices = allVoices.filter((v) => v.lang.toLowerCase().startsWith('vi'))
      const available = viVoices.length > 0 ? viVoices : allVoices
      setVoices(available)

      if (available.length > 0) {
        let matched = available.find((v) => v.voiceURI === initialSettings.voiceURI)
        if (!matched && viVoices.length > 0) {
          matched = viVoices[0]
        }
        setVoiceState(matched || available[0])
      }
    }

    updateVoices()
    window.speechSynthesis.onvoiceschanged = updateVoices

    return () => {
      window.speechSynthesis.onvoiceschanged = null
    }
  }, [supported])

  const setVoice = useCallback((v: SpeechSynthesisVoice) => {
    setVoiceState(v)
    saveStoredTtsSettings({ voiceURI: v.voiceURI })
  }, [])

  const setRate = useCallback((r: number) => {
    const clamped = Math.max(0.8, Math.min(2.0, r))
    setRateState(clamped)
    saveStoredTtsSettings({ rate: clamped })
  }, [])

  const speakNextSentenceRef = useRef<() => void>(() => {})

  // 2. Vòng lặp đọc từng câu
  const speakNextSentence = useCallback(() => {
    if (!supported || !isPlayingRef.current) return

    const sList = sentencesRef.current
    const idx = sentenceIndexRef.current

    if (idx >= sList.length) {
      // Hết chương: sang chương tiếp theo và tiếp tục đọc
      if (!reader.isLastChapter) {
        pendingNextChapterRef.current = true
        reader.nextChapter()
      } else {
        // Hết sách
        isPlayingRef.current = false
        setPlaying(false)
        setCurrent(null)
        sentenceIndexRef.current = 0
      }
      return
    }

    const item = sList[idx]
    setCurrent(item)

    // Nếu câu vượt ra khỏi trang đang hiển thị thì tự lật trang
    if (item.start < paginator.pageRange.start || item.start >= paginator.pageRange.end) {
      paginator.goToOffset(item.start)
    }

    const utterance = new SpeechSynthesisUtterance(item.text)
    if (voiceRef.current) {
      utterance.voice = voiceRef.current
    }
    utterance.lang = voiceRef.current?.lang || 'vi-VN'
    utterance.rate = rateRef.current

    utterance.onend = () => {
      if (isPlayingRef.current) {
        sentenceIndexRef.current++
        speakNextSentenceRef.current()
      }
    }

    utterance.onerror = (e) => {
      if (e.error === 'interrupted' || e.error === 'canceled') return
      if (isPlayingRef.current) {
        sentenceIndexRef.current++
        speakNextSentenceRef.current()
      }
    }

    window.speechSynthesis.speak(utterance)
  }, [supported, reader, paginator])

  useEffect(() => {
    speakNextSentenceRef.current = speakNextSentence
  }, [speakNextSentence])

  // 3. Tự động đọc tiếp khi sang chương mới
  useEffect(() => {
    if (pendingNextChapterRef.current && sentences.length > 0) {
      pendingNextChapterRef.current = false
      sentenceIndexRef.current = 0
      speakNextSentence()
    }
  }, [sentences, speakNextSentence])

  // 4. Các hành động điều khiển: play, pause, stop
  const play = useCallback(
    (fromOffset?: number) => {
      if (!supported) return

      const sList = sentencesRef.current
      if (sList.length === 0) return

      let targetIdx = sentenceIndexRef.current
      if (typeof fromOffset === 'number') {
        const found = sList.findIndex((s) => s.start <= fromOffset && s.end >= fromOffset)
        targetIdx = found >= 0 ? found : sList.findIndex((s) => s.start >= fromOffset)
        if (targetIdx < 0) targetIdx = 0
      } else if (!isPlayingRef.current && current === null) {
        // Bắt đầu từ đầu trang đang xem
        const pStart = paginator.pageRange.start
        const found = sList.findIndex((s) => s.start >= pStart)
        targetIdx = found >= 0 ? found : 0
      }

      sentenceIndexRef.current = Math.max(0, targetIdx)
      isPlayingRef.current = true
      setPlaying(true)

      window.speechSynthesis.cancel()
      speakNextSentence()
    },
    [supported, current, paginator.pageRange.start, speakNextSentence],
  )

  const pause = useCallback(() => {
    if (!supported) return
    isPlayingRef.current = false
    setPlaying(false)
    window.speechSynthesis.cancel()
  }, [supported])

  const stop = useCallback(() => {
    if (!supported) return
    isPlayingRef.current = false
    setPlaying(false)
    setCurrent(null)
    sentenceIndexRef.current = 0
    window.speechSynthesis.cancel()
  }, [supported])

  // Dọn dẹp khi unmount
  useEffect(() => {
    return () => {
      if (supported) {
        window.speechSynthesis.cancel()
      }
    }
  }, [supported])

  return {
    supported,
    voices,
    voice,
    setVoice,
    rate,
    setRate,
    playing,
    current,
    play,
    pause,
    stop,
  }
}
