(function () {
    const page = document.querySelector(".spectator-teams");
    if (!page) return;

    const UI = window.SpectatorUI;
    const teamList = document.getElementById("teamList");
    const empty = document.getElementById("empty");
    const message = document.getElementById("pageMessage");
    const api = page.dataset.teamsApi;
    const detailUrl = page.dataset.detailUrl;

    async function load() {
        try {
            const payload = await UI.requestJson(api);
            const teams = Array.isArray(payload.data) ? payload.data : [];
            empty.classList.toggle("hidden", teams.length > 0);

            teamList.innerHTML = teams.map((team) => `
                <a class="spectator-card team-card" href="${UI.escapeHtml(detailUrl)}?id=${encodeURIComponent(team.iddoibong)}">
                    <img src="${UI.escapeHtml(team.logo || "https://placehold.co/96x96?text=VTMS")}" alt="">
                    <div class="name">${UI.escapeHtml(team.tendoibong || "-")}</div>
                    <div class="location">${UI.escapeHtml(team.diaphuong || "-")}</div>
                    <p class="sub">${UI.escapeHtml(team.active_members ?? 0)} thành viên • ${UI.escapeHtml(team.public_tournaments ?? 0)} giải</p>
                </a>
            `).join("");
        } catch (error) {
            UI.showMessage(message, error.message);
            teamList.innerHTML = "";
            empty.classList.remove("hidden");
        }
    }

    load();
})();
