"""sandol_logo.png -> 런처 아이콘 소스 이미지 생성.

- app_icon.png: 1024x1024 풀블리드 (iOS / 레거시 Android용).
  배경은 로고 왼쪽 가장자리에서 추출한 세로 그라데이션으로 채워
  로고 축소 시에도 이음새 없이 자연스럽게 여백이 생긴다.
- app_icon_foreground.png: 1024x1024 투명 캔버스에 로고를 중앙 배치
  (Android adaptive foreground). adaptive 아이콘은 캔버스의 중앙 72/108만
  표시되므로, iOS(92%)와 같은 꽉 찬 느낌을 내려면 표시 영역 기준으로
  스케일을 잡아야 한다.
- app_icon_bg.png: adaptive background 레이어용 그라데이션 (iOS 아이콘과
  동일한 배경 → 로고 밖 여백이 민무늬 대신 그라데이션으로 채워진다).

실행: python3 scripts/make_app_icons.py && dart run flutter_launcher_icons
"""
import os
from PIL import Image

SRC = "/Users/songjeonghun/Handori/assets/img/sandol_logo.png"
OUT_DIR = "/Users/songjeonghun/Handori/assets/icon"
SIZE = 1024
MAIN_SCALE = 0.92  # 풀블리드 아이콘에서 로고가 차지하는 비율 (여백 조절)
# adaptive 표시 영역(72/108)에 거의 꽉 차는 크기. 0.667이 표시 영역 경계.
FG_SCALE = 0.66

os.makedirs(OUT_DIR, exist_ok=True)

logo = Image.open(SRC).convert("RGBA")
logo = logo.crop(logo.getbbox())  # 투명 여백 제거
w, h = logo.size
print("trimmed:", logo.size)

# 각 행의 왼쪽 가장자리 안쪽 색을 뽑아 세로 그라데이션 배경 생성
column = []
last = None
for y in range(h):
    color = None
    for x in range(w):
        r, g, b, a = logo.getpixel((x, y))
        if a > 250:
            color = logo.getpixel((min(x + 12, w - 1), y))[:3]
            break
    last = color or last
    column.append(last)
# 상단의 완전 투명 행은 아래쪽 첫 유효 색으로 채움
first_valid = next(c for c in column if c)
column = [c or first_valid for c in column]

grad = Image.new("RGB", (1, h))
grad.putdata(column)
bg = grad.resize((SIZE, SIZE), Image.LANCZOS).convert("RGBA")

# 1) 풀블리드 정사각 아이콘: 그라데이션 배경 위에 로고 축소 배치
scale = MAIN_SCALE * SIZE / max(w, h)
lw, lh = int(w * scale), int(h * scale)
main = bg.copy()
main.alpha_composite(
    logo.resize((lw, lh), Image.LANCZOS),
    ((SIZE - lw) // 2, (SIZE - lh) // 2),
)
main.convert("RGB").save(f"{OUT_DIR}/app_icon.png")
print("saved app_icon.png (scale %.2f)" % MAIN_SCALE)

# 2) adaptive foreground: 투명 캔버스 중앙 배치
fg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
scale = FG_SCALE * SIZE / max(w, h)
lw, lh = int(w * scale), int(h * scale)
fg.alpha_composite(
    logo.resize((lw, lh), Image.LANCZOS),
    ((SIZE - lw) // 2, (SIZE - lh) // 2),
)
fg.save(f"{OUT_DIR}/app_icon_foreground.png")
print("saved app_icon_foreground.png (scale %.2f)" % FG_SCALE)

# 3) adaptive background: iOS 와 동일한 그라데이션 풀캔버스
bg.convert("RGB").save(f"{OUT_DIR}/app_icon_bg.png")
print("saved app_icon_bg.png")

mid = column[h // 2]
print("adaptive bg hex: #%02X%02X%02X" % mid)
