(function () {
    window.SpectatorUI = {
        escapeHtml(value) {
            return String(value ?? "")
                .replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/"/g, "&quot;")
                .replace(/'/g, "&#039;");
        },

        async requestJson(url, options = {}) {
            const response = await fetch(url, {
                headers: {
                    Accept: "application/json",
                    "Content-Type": "application/json",
                    ...(options.headers || {}),
                },
                credentials: "same-origin",
                ...options,
            });
            const payload = await response.json().catch(() => ({}));

            if (!response.ok || payload.success === false) {
                const error = new Error(payload.message || "Yêu cầu không thành công.");
                error.status = response.status;
                error.payload = payload;
                throw error;
            }

            return payload;
        },

        formatDateTime(value) {
            return String(value || "").replace("T", " ");
        },

        score(row) {
            const setOne = row.sosetdoi1 ?? row.sets_team_one;
            const setTwo = row.sosetdoi2 ?? row.sets_team_two;
            if (setOne !== null && setOne !== undefined && setTwo !== null && setTwo !== undefined) {
                return `${setOne} - ${setTwo}`;
            }

            const pointOne = row.diemdoi1 ?? row.score_team_one;
            const pointTwo = row.diemdoi2 ?? row.score_team_two;
            if (pointOne !== null && pointOne !== undefined && pointTwo !== null && pointTwo !== undefined) {
                return `${pointOne} - ${pointTwo}`;
            }

            return "-";
        },

        showMessage(el, message) {
            if (!el) return;
            el.textContent = message || "";
        },
    };
})();
