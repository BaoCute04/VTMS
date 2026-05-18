(function () {
    const page = document.querySelector(".spectator-team-detail");
    if (!page) return;

    const UI = window.SpectatorUI;
    const api = page.dataset.teamsApi;
    const id = new URLSearchParams(window.location.search).get("id");
    const notFound = document.getElementById("notFound");
    const message = document.getElementById("pageMessage");

    async function load() {
        if (!id) {
            notFound.classList.remove("hidden");
            return;
        }

        try {
            const payload = await UI.requestJson(`${api}/${encodeURIComponent(id)}`);
            const team = payload.data || {};
            const tournaments = Array.isArray(payload.tournaments) ? payload.tournaments : [];
            const members = Array.isArray(payload.members) ? payload.members : [];

            document.getElementById("logo").src = team.logo || "https://placehold.co/120x120?text=VTMS";
            document.getElementById("name").textContent = team.tendoibong || "-";
            document.getElementById("location").textContent = team.diaphuong || "-";
            document.getElementById("description").textContent = team.mota || "Chưa có giới thiệu.";
            document.getElementById("sport").textContent = "Bóng chuyền";
            document.getElementById("tournament").textContent = tournaments.map((item) => item.tengiaidau).filter(Boolean).join(", ") || "-";
            document.getElementById("coach").textContent = team.huanluyenvien_hoten || team.huanluyenvien_username || "-";
            document.getElementById("members").innerHTML = members.length === 0
                ? `<tr><td colspan="3" class="empty">Chưa có thành viên công khai.</td></tr>`
                : members.map((member) => `
                    <tr>
                        <td>${UI.escapeHtml(member.hoten || "-")}</td>
                        <td>${UI.escapeHtml(member.vaitrotrongdoi || "-")}</td>
                        <td>${UI.escapeHtml(member.vitri || "-")}</td>
                    </tr>
                `).join("");
        } catch (error) {
            UI.showMessage(message, error.message);
            notFound.classList.remove("hidden");
        }
    }

    load();
})();
