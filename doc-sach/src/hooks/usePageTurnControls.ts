import { useEffect, useRef } from 'react'

export interface PageTurnControlsOptions {
  containerRef: React.RefObject<HTMLElement | null>
  onNext: () => void
  onPrev: () => void
  onToggleToolbar?: () => void
  disabled?: boolean
}

const SWIPE_THRESHOLD = 40

export function usePageTurnControls({
  containerRef,
  onNext,
  onPrev,
  onToggleToolbar,
  disabled = false,
}: PageTurnControlsOptions): void {
  const startXRef = useRef(0)
  const startYRef = useRef(0)
  const isPointerDownRef = useRef(false)
  const isDraggingRef = useRef(false)

  // 1. Phím mũi tên, Space, PageUp, PageDown
  useEffect(() => {
    if (disabled) return

    const onKeyDown = (e: KeyboardEvent) => {
      const active = document.activeElement
      if (
        active &&
        (active.tagName === 'INPUT' ||
          active.tagName === 'TEXTAREA' ||
          (active as HTMLElement).isContentEditable)
      ) {
        return
      }

      if (e.key === 'ArrowRight' || e.key === 'PageDown' || (e.key === ' ' && !e.shiftKey)) {
        e.preventDefault()
        onNext()
      } else if (e.key === 'ArrowLeft' || e.key === 'PageUp' || (e.key === ' ' && e.shiftKey)) {
        e.preventDefault()
        onPrev()
      }
    }

    window.addEventListener('keydown', onKeyDown)
    return () => {
      window.removeEventListener('keydown', onKeyDown)
    }
  }, [disabled, onNext, onPrev])

  // 2. Pointer events: vuốt ngang và chạm phân vùng
  useEffect(() => {
    const container = containerRef.current
    if (!container || disabled) return

    const onPointerDown = (e: PointerEvent) => {
      // Chỉ nhận chuột trái hoặc cảm ứng
      if (e.button !== 0 && e.pointerType === 'mouse') return

      startXRef.current = e.clientX
      startYRef.current = e.clientY
      isPointerDownRef.current = true
      isDraggingRef.current = false
    }

    const onPointerMove = (e: PointerEvent) => {
      if (!isPointerDownRef.current) return
      const dx = Math.abs(e.clientX - startXRef.current)
      const dy = Math.abs(e.clientY - startYRef.current)
      if (dx > 10 || dy > 10) {
        isDraggingRef.current = true
      }
    }

    const onPointerUp = (e: PointerEvent) => {
      if (!isPointerDownRef.current) return
      isPointerDownRef.current = false

      const deltaX = e.clientX - startXRef.current
      const deltaY = e.clientY - startYRef.current
      const absX = Math.abs(deltaX)
      const absY = Math.abs(deltaY)

      // Kiểm tra vuốt ngang
      if (absX >= SWIPE_THRESHOLD && absX > absY) {
        if (deltaX < 0) {
          onNext()
        } else {
          onPrev()
        }
        return
      }

      // Nếu không phải vuốt mà là chạm (tap)
      if (!isDraggingRef.current) {
        // Nếu người dùng đang bôi đen chữ (tạo highlight/ghi chú), bỏ qua chạm
        const selection = window.getSelection()
        if (selection && selection.toString().trim().length > 0) {
          return
        }

        // Bỏ qua nếu chạm vào nút, thẻ a hoặc phần tử tương tác
        const target = e.target as HTMLElement | null
        if (
          target?.closest('button') ||
          target?.closest('a') ||
          target?.closest('input') ||
          target?.closest('[role="button"]') ||
          target?.closest('[data-interactive="true"]')
        ) {
          return
        }

        const rect = container.getBoundingClientRect()
        const clickRatio = (e.clientX - rect.left) / rect.width

        if (clickRatio < 0.3) {
          // 30% bên trái: Lùi trang
          onPrev()
        } else if (clickRatio > 0.7) {
          // 30% bên phải: Sang trang
          onNext()
        } else {
          // 40% ở giữa: Bật / tắt thanh công cụ
          onToggleToolbar?.()
        }
      }
    }

    const onPointerCancel = () => {
      isPointerDownRef.current = false
      isDraggingRef.current = false
    }

    container.addEventListener('pointerdown', onPointerDown)
    container.addEventListener('pointermove', onPointerMove)
    container.addEventListener('pointerup', onPointerUp)
    container.addEventListener('pointercancel', onPointerCancel)

    return () => {
      container.removeEventListener('pointerdown', onPointerDown)
      container.removeEventListener('pointermove', onPointerMove)
      container.removeEventListener('pointerup', onPointerUp)
      container.removeEventListener('pointercancel', onPointerCancel)
    }
  }, [containerRef, disabled, onNext, onPrev, onToggleToolbar])
}
