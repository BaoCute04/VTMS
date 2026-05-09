(function () {
    const root = document.querySelector(".coach-tournaments");
    if (!root) return;

    const ui = window.CoachUI;
    const tournamentsApi = root.dataset.tournamentsApi || "/api/coach/tournaments";
    const registrationsApi = root.dataset.registrationsApi || "/api/coach/tournament-registrations";
    const teamsApi = root.dataset.teamsApi || "/api/coach/teams";

    const tbody = document.getElementById("tbody");
    const q = document.getElementById("q");
    const modal = document.getElementById("detailModal");
    const alertBox = document.getElementById("d_alert");
    const pageMessage = document.getElementById("pageMessage");
    const teamSelect = document.getElementById("d_team");

    let tournaments = [];
    let teams = [];
    let current = null;

    function dateRange(from, to) {
        return `${from || "-"} - ${to || "-"}`;
    }

    function statusLabel(tournament) {
        if (tournament.trangthaidangky === "DANG_MO") return "Đang mở đăng ký";
        if (tournament.trangthaidangky === "DANG_DONG") return "Đã đóng đăng ký";
        return tournament.trangthaidangky || tournament.trangthai || "-";
    }

    function render() {
        if (tournaments.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" class="empty">Không có giải đấu đang mở đăng ký.</td></tr>';
            return;
        }

        tbody.innerHTML = tournaments.map((tournament) => {
            const [badgeClass, label] = ui.badge(tournament.trangthaidangky);
            return `
                <tr>
                    <td>${ui.escapeHtml(tournament.tengiaidau)}</td>
                    <td>${ui.escapeHtml(dateRange(tournament.ngaytao, tournament.thoigianbatdau))}</td>
                    <td>${ui.escapeHtml(dateRange(tournament.thoigianbatdau, tournament.thoigianketthuc))}</td>
                    <td>${ui.escapeHtml(tournament.approved_registrations || 0)} / ${ui.escapeHtml(tournament.quymo || 0)}</td>
                    <td><span class="badge ${badgeClass}">${ui.escapeHtml(label)}</span></td>
                    <td><button class="btn" type="button" data-action="view" data-id="${ui.escapeHtml(tournament.idgiaidau)}">Xem</button></td>
                </tr>
            `;
        }).join("");
    }

    async function load() {
        ui.show(pageMessage, "");
        const params = { q: q.value.trim() };
        const [tournamentPayload, teamPayload] = await Promise.all([
            ui.requestJson(ui.apiUrl(tournamentsApi, params)),
            ui.requestJson(teamsApi),
        ]);
        tournaments = tournamentPayload.data || [];
        teams = teamPayload.data || [];
        ui.fillSelect(teamSelect, teams, "iddoibong", "tendoibong", "Chọn đội bóng");
        render();
    }

    function openDetail(id) {
        current = tournaments.find((item) => Number(item.idgiaidau) === Number(id));
        if (!current) return;
        ui.hideAlert(alertBox);
        document.getElementById("d_name").textContent = current.tengiaidau || "Chi tiết giải đấu";
        document.getElementById("d_registerTime").value = dateRange(current.ngaytao, current.thoigianbatdau);
        document.getElementById("d_playTime").value = dateRange(current.thoigianbatdau, current.thoigianketthuc);
        document.getElementById("d_status").value = statusLabel(current);
        document.getElementById("d_desc").value = current.mota || "";
        modal.classList.remove("hidden");
    }

    tbody.addEventListener("click", (event) => {
        const button = event.target.closest("button[data-action='view']");
        if (button) openDetail(button.dataset.id);
    });

    document.getElementById("d_close").addEventListener("click", () => modal.classList.add("hidden"));
    document.getElementById("d_cancel").addEventListener("click", () => modal.classList.add("hidden"));
    document.getElementById("btnRefresh").addEventListener("click", () => load().catch((error) => ui.show(pageMessage, ui.errorsText(error), true)));
    q.addEventListener("input", () => load().catch(() => {}));

    document.getElementById("btnRegister").addEventListener("click", async () => {
        ui.hideAlert(alertBox);
        if (!current) return;
        if (!teamSelect.value) {
            ui.showAlert(alertBox, "Vui lòng chọn đội bóng đăng ký.");
            return;
        }

        try {
            const result = await ui.requestJson(`${registrationsApi}`, {
                method: "POST",
                body: JSON.stringify({
                    idgiaidau: current.idgiaidau,
                    iddoibong: teamSelect.value,
                }),
            });
            modal.classList.add("hidden");
            ui.show(pageMessage, result.message || "Đã gửi đăng ký, chờ duyệt.");
            await load();
        } catch (error) {
            ui.showAlert(alertBox, ui.errorsText(error));
        }
    });

    load().catch((error) => ui.show(pageMessage, ui.errorsText(error), true));
})();
