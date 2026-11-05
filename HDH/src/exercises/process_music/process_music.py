#!/usr/bin/env python3
"""
Học phần: HỆ ĐIỀU HÀNH - ĐẠI HỌC BÁCH KHOA HÀ NỘI (HUST)
Minh họa quản lý tiến trình bằng Python (os.fork, os.execvp, os.waitpid)
"""

import os
import sys
import wave
import math
import struct
import shutil

SAMPLE_RATE = 22050
DEFAULT_WAV = "sample_melody_py.wav"

def generate_sample_wav(filename):
    """Tự động sinh file âm thanh WAV với giai điệu ngắn vui vẻ."""
    # Nốt nhạc (Hz)
    notes = [
        329.63, 329.63, 349.23, 392.00,  # E E F G
        392.00, 349.23, 329.63, 293.66,  # G F E D
        261.63, 261.63, 293.66, 329.63,  # C C D E
        329.63, 293.66, 293.66           # E D D
    ]
    durations = [
        0.22, 0.22, 0.22, 0.22,
        0.22, 0.22, 0.22, 0.22,
        0.22, 0.22, 0.22, 0.22,
        0.30, 0.15, 0.35
    ]
    
    with wave.open(filename, 'w') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(SAMPLE_RATE)
        for freq, dur in zip(notes, durations):
            n_samples = int(SAMPLE_RATE * dur)
            for i in range(n_samples):
                t = i / SAMPLE_RATE
                # Envelope làm mượt âm thanh
                env = min(1.0, i / (SAMPLE_RATE * 0.01)) * min(1.0, (n_samples - i) / (SAMPLE_RATE * 0.02))
                val = int(16000 * env * math.sin(2 * math.pi * freq * t))
                f.writeframes(struct.pack('<h', val))

def speak(text):
    """Phát âm thanh giọng nói nếu có spd-say"""
    if shutil.which("spd-say"):
        pid = os.fork()
        if pid == 0:
            devnull = os.open(os.devnull, os.O_WRONLY)
            os.dup2(devnull, 1)
            os.dup2(devnull, 2)
            os.execvp("spd-say", ["spd-say", "-t", "female1", text])
        else:
            os.waitpid(pid, 0)

def main():
    if len(sys.argv) > 1:
        music_file = sys.argv[1]
    else:
        print(f"ℹ️  Đang khởi tạo bản nhạc mẫu '{DEFAULT_WAV}'...")
        generate_sample_wav(DEFAULT_WAV)
        music_file = DEFAULT_WAV

    print("=" * 70)
    print("   BÀI TẬP TIẾN TRÌNH HỆ ĐIỀU HÀNH (PYTHON: fork - exec - wait)")
    print("=" * 70)
    print(f"\033[1;33m[TIẾN TRÌNH CHA - PID: {os.getpid()}]\033[0m: Chuẩn bị os.fork() tạo tiến trình con...")

    # 1. FORK TIẾN TRÌNH
    pid = os.fork()

    if pid < 0:
        print("❌ Lỗi fork() tiến trình!")
        sys.exit(1)
    elif pid == 0:
        # ==========================================
        # TIẾN TRÌNH CON
        # ==========================================
        print(f"\n\033[1;36m[TIẾN TRÌNH CON - PID: {os.getpid()}, PPID: {os.getppid()}]\033[0m")
        print(f"🎵 Đang phát bản nhạc: '{music_file}'...")
        
        # Tìm trình phát nhạc có sẵn
        for player in ["aplay", "paplay", "canberra-gtk-play", "ffplay", "mpv"]:
            if shutil.which(player):
                if player == "aplay":
                    os.execvp(player, [player, "-q", music_file])
                elif player == "canberra-gtk-play":
                    os.execvp(player, [player, "-f", music_file])
                else:
                    os.execvp(player, [player, music_file])
        
        print("❌ Không tìm thấy trình phát nhạc nào trên máy.")
        os._exit(1)
    else:
        # ==========================================
        # TIẾN TRÌNH CHA
        # ==========================================
        print(f"\033[1;33m[TIẾN TRÌNH CHA - PID: {os.getpid()}]\033[0m: Đã sinh ra tiến trình con PID: {pid}.")
        print(f"\033[1;33m[TIẾN TRÌNH CHA - PID: {os.getpid()}]\033[0m: Đang gọi os.waitpid() để đợi tiến trình con...")

        _, exit_code = os.waitpid(pid, 0)
        print("\n" + "-" * 70)
        print(f"✅ [HỆ THỐNG]: Tiến trình con (PID: {pid}) đã hoàn thành xong bản nhạc! (Exit code: {exit_code >> 8})")
        print("-" * 70 + "\n")

        # Phát bảng tin
        print("\033[1;32m" + "=" * 70)
        print(f"      📢 BẢNG TIN PHÁT THANH TỪ TIẾN TRÌNH CHA (PARENT PID: {os.getpid()})")
        print("=" * 70 + "\033[0m")
        print("🔊 \033[1m\"Alo alo! Bản tin thông báo đặc biệt:\033[0m")
        print("   1. Tiến trình vừa rồi nghe có hay không ạ?")
        print("   2. Bản nhạc đã kết thúc, xin vui lòng quay về học phần Hệ Điều Hành!")
        print("   3. Quý vị chấm điểm tiến trình vừa rồi mấy sao (1 đến 5 sao)?\"")
        print("\033[1;32m" + "=" * 70 + "\033[0m\n")

        speak("Tien trinh phat nhac da xong. Xin moi quay ve hoc phan he dieu hanh!")

        try:
            val = input("👉 Xin mời nhập số sao đánh giá (1 - 5): ").strip()
            rating = int(val)
            print("\n\033[1;35m[PHẢN HỒI TỪ TIẾN TRÌNH CHA]:\033[0m")
            if rating == 5:
                print("⭐⭐⭐⭐⭐ Tuyệt vời! Điểm A+ môn Hệ Điều Hành!")
            elif rating == 4:
                print("⭐⭐⭐⭐ Rất tốt! Lập lịch tiến trình mượt mà.")
            elif rating == 3:
                print("⭐⭐⭐ Tạm ổn! Cần tối ưu IPC và tránh Context Switch dư thừa.")
            else:
                print("⭐ Hãy cẩn thận tránh Deadlock và Starvation nhé!")
        except Exception:
            print("Cảm ơn bạn đã tham gia đánh giá!")

        print(f"\n\033[1;33m[TIẾN TRÌNH CHA - PID: {os.getpid()}]\033[0m: Kết thúc chương trình. Tạm biệt!\n")

if __name__ == "__main__":
    main()
