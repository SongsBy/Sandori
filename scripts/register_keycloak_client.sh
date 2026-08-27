#!/usr/bin/env bash
# Handori 앱용 Keycloak public client(handori-app)를 Sandori realm 에 등록한다.
#
# 로컬 (docker 컨테이너 'keycloak' 기준):
#   ./scripts/register_keycloak_client.sh
# 프로덕션: 프로덕션 Keycloak 이 있는 서버에서 컨테이너 이름만 바꿔 실행하거나,
#   관리 콘솔(https://sandori.kr/auth)에서 아래 JSON 과 동일하게 수동 생성.
#
# 앱 쪽 상수와 반드시 일치해야 한다 (lib/core/constants/api_constants.dart):
#   client id      : handori-app
#   redirect URI   : kr.sandori.handori://oauthredirect
#   PKCE           : S256 필수
set -euo pipefail

CONTAINER="${KEYCLOAK_CONTAINER:-keycloak}"
REALM="Sandori"
CLIENT_ID="handori-app"
REDIRECT_URI="kr.sandori.handori://oauthredirect"

KCADM="/opt/keycloak/bin/kcadm.sh"

echo "── kcadm 로그인 (컨테이너 내부 부트스트랩 계정 사용) ──"
docker exec "$CONTAINER" sh -c \
  "$KCADM config credentials --server http://localhost:8080 --realm master \
     --user \"\${KC_BOOTSTRAP_ADMIN_USERNAME:-\$KEYCLOAK_ADMIN}\" \
     --password \"\${KC_BOOTSTRAP_ADMIN_PASSWORD:-\$KEYCLOAK_ADMIN_PASSWORD}\""

echo "── 기존 클라이언트 확인 ──"
EXISTING_ID=$(docker exec "$CONTAINER" sh -c \
  "$KCADM get clients -r $REALM -q clientId=$CLIENT_ID --fields id --format csv --noquotes" | tr -d '\r')

CLIENT_JSON=$(cat <<JSON
{
  "clientId": "$CLIENT_ID",
  "name": "Handori Flutter App",
  "enabled": true,
  "publicClient": true,
  "standardFlowEnabled": true,
  "directAccessGrantsEnabled": false,
  "implicitFlowEnabled": false,
  "serviceAccountsEnabled": false,
  "redirectUris": ["$REDIRECT_URI"],
  "webOrigins": [],
  "attributes": {
    "pkce.code.challenge.method": "S256",
    "post.logout.redirect.uris": "$REDIRECT_URI"
  }
}
JSON
)

if [ -n "$EXISTING_ID" ]; then
  echo "이미 존재($EXISTING_ID) → 설정 업데이트"
  docker exec -i "$CONTAINER" sh -c "$KCADM update clients/$EXISTING_ID -r $REALM -f -" <<<"$CLIENT_JSON"
else
  echo "신규 생성"
  docker exec -i "$CONTAINER" sh -c "$KCADM create clients -r $REALM -f -" <<<"$CLIENT_JSON"
fi

echo "── 등록 결과 ──"
docker exec "$CONTAINER" sh -c \
  "$KCADM get clients -r $REALM -q clientId=$CLIENT_ID --fields clientId,enabled,publicClient,redirectUris,attributes(pkce.code.challenge.method)"

cat <<'EOF'

완료. 로컬 테스트용 계정이 필요하면:
  docker exec keycloak /opt/keycloak/bin/kcadm.sh create users -r Sandori \
    -s username=handori-test -s enabled=true
  docker exec keycloak /opt/keycloak/bin/kcadm.sh set-password -r Sandori \
    --username handori-test --new-password <비밀번호>
EOF
