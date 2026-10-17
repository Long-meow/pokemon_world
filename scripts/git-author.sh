#!/usr/bin/env bash
# Helper script to set Git author/committer identity for student team members
# Usage: source scripts/git-author.sh [dung|tien|long]

case "$1" in
    dung)
        export GIT_AUTHOR_NAME="Nguyen Van Dung"
        export GIT_AUTHOR_EMAIL="dung.nv@fpt.edu.vn"
        export GIT_COMMITTER_NAME="Nguyen Van Dung"
        export GIT_COMMITTER_EMAIL="dung.nv@fpt.edu.vn"
        echo "[INFO] Git author identity set to: Nguyen Van Dung <dung.nv@fpt.edu.vn>"
        ;;
    tien)
        export GIT_AUTHOR_NAME="Tran Minh Tien"
        export GIT_AUTHOR_EMAIL="tien.tm@fpt.edu.vn"
        export GIT_COMMITTER_NAME="Tran Minh Tien"
        export GIT_COMMITTER_EMAIL="tien.tm@fpt.edu.vn"
        echo "[INFO] Git author identity set to: Tran Minh Tien <tien.tm@fpt.edu.vn>"
        ;;
    long)
        export GIT_AUTHOR_NAME="Hoang Phi Long"
        export GIT_AUTHOR_EMAIL="long.hp@fpt.edu.vn"
        export GIT_COMMITTER_NAME="Hoang Phi Long"
        export GIT_COMMITTER_EMAIL="long.hp@fpt.edu.vn"
        echo "[INFO] Git author identity set to: Hoang Phi Long <long.hp@fpt.edu.vn>"
        ;;
    *)
        echo "Usage: source scripts/git-author.sh [dung|tien|long]"
        ;;
esac
