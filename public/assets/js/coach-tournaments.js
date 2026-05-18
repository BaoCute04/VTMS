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
    const teamRegistration = document.getElementById("d_teamRegistration");
    const registerButton = document.getElementById("btnRegister");

    let tournaments = [];
    let teams = [];
    let current = null;
    let currentRegistrations = [];

    const registrationStatusText = {
        CHO_DUYET: "Chờ duyệt",
        DA_DUYET: "Đã duyệt",
        TU_CHOI: "Từ chối",
        DA_HUY: "Đã hủy",
    };

    function dateRange(from, to) {
        return `${from || "-"} - ${to || "-"}`;
    }

    function statusLabel(tournament) {
        if (tournament.trangthaidangky === "DANG_MO") return "Đang mở đăng ký";
        if (tournament.trangthaidangky === "DA_DONG") return "Đã đóng đăng ký";
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
        fillTeamSelect();
        render();
    }

    function registrationStatusLabel(status) {
        return registrationStatusText[status] || status || "-";
    }

    function registrationForTeam(teamId) {
        return currentRegistrations.find((registration) => Number(registration.iddoibong) === Number(teamId)) || null;
    }

    function registrationForSelectedTeam() {
        const teamId = Number(teamSelect.value || 0);
        if (!teamId) return null;

        return registrationForTeam(teamId);
    }

    function eligibleTeamIdsForCurrentTournament() {
        if (!current || !Array.isArray(current.eligible_team_ids)) return null;

        return current.eligible_team_ids.map((id) => Number(id));
    }

    function isTeamEligibleForCurrentTournament(teamId) {
        const eligibleIds = eligibleTeamIdsForCurrentTournament();
        if (eligibleIds === null) return true;

        return eligibleIds.includes(Number(teamId));
    }

    function eligibleTeamsForCurrentTournament() {
        return teams.filter((team) => isTeamEligibleForCurrentTournament(team.iddoibong));
    }

    function fillTeamSelect(selectedTeamId = "") {
        if (!teamSelect) return;

        const selectedValue = selectedTeamId || teamSelect.value || "";
        const options = ['<option value="">Chọn đội bóng</option>'];
        const visibleTeams = eligibleTeamsForCurrentTournament();

        visibleTeams.forEach((team) => {
            const registration = registrationForTeam(team.iddoibong);
            const status = registration
                ? `Đã đăng ký - ${registrationStatusLabel(registration.trangthai)}`
                : "Chưa đăng ký";
            options.push(
                `<option value="${ui.escapeHtml(team.iddoibong)}">${ui.escapeHtml(team.tendoibong)} (${ui.escapeHtml(status)})</option>`
            );
        });

        if (visibleTeams.length === 0) {
            options.push('<option value="" disabled>Không có đội đủ điều kiện đăng ký</option>');
        }

        teamSelect.innerHTML = options.join("");
        teamSelect.value = isTeamEligibleForCurrentTournament(selectedValue) ? selectedValue : "";
    }

    function renderTeamRegistrationState() {
        if (!teamSelect.value) {
            teamRegistration.classList.add("hidden");
            teamRegistration.innerHTML = "";
            registerButton.disabled = true;
            registerButton.textContent = "Đăng ký giải";

            if (current && eligibleTeamsForCurrentTournament().length === 0) {
                teamRegistration.classList.remove("hidden");
                teamRegistration.innerHTML = "Không có đội bóng nào của bạn đáp ứng điều kiện tham gia giải đấu này.";
            }
            return;
        }

        const selectedTeam = teams.find((team) => Number(team.iddoibong) === Number(teamSelect.value));
        const registration = registrationForSelectedTeam();
        teamRegistration.classList.remove("hidden");

        if (!registration) {
            teamRegistration.innerHTML = `<strong>${ui.escapeHtml(selectedTeam?.tendoibong || "Đội bóng")}</strong> chưa đăng ký tham gia giải đấu này.`;
            registerButton.disabled = false;
            registerButton.textContent = "Đăng ký giải";
            return;
        }

        const [badgeClass, badgeLabel] = ui.badge(registration.trangthai);
        const extra = [
            registration.ngaydangky ? `Ngày gửi: ${ui.escapeHtml(registration.ngaydangky)}` : "",
            registration.lydotuchoi ? `Lý do từ chối/hủy: ${ui.escapeHtml(registration.lydotuchoi)}` : "",
        ].filter(Boolean).join(" • ");
        teamRegistration.innerHTML = `
            <strong>${ui.escapeHtml(selectedTeam?.tendoibong || registration.tendoibong || "Đội bóng")}</strong>
            đã có hồ sơ đăng ký tham gia giải đấu.
            <span class="badge ${badgeClass}">${ui.escapeHtml(badgeLabel)}</span>
            ${extra ? `<span class="state-detail">${extra}</span>` : ""}
        `;
        registerButton.disabled = true;
        registerButton.textContent = "Đội đã đăng ký";
    }

    async function loadTournamentRegistrations(tournamentId) {
        const payload = await ui.requestJson(ui.apiUrl(registrationsApi, { tournament_id: tournamentId }));
        currentRegistrations = payload.data || [];
        fillTeamSelect();
        renderTeamRegistrationState();
    }

    async function openDetail(id) {
        current = tournaments.find((item) => Number(item.idgiaidau) === Number(id));
        if (!current) return;
        currentRegistrations = [];
        teamSelect.value = "";
        ui.hideAlert(alertBox);
        document.getElementById("d_name").textContent = current.tengiaidau || "Chi tiết giải đấu";
        document.getElementById("d_registerTime").value = dateRange(current.ngaytao, current.thoigianbatdau);
        document.getElementById("d_playTime").value = dateRange(current.thoigianbatdau, current.thoigianketthuc);
        document.getElementById("d_status").value = statusLabel(current);
        document.getElementById("d_desc").textContent = current.mota || "Không có mô tả.";
        document.getElementById("d_ruleTitle").textContent = current.dieule_tieude || "Điều lệ giải đấu";
        document.getElementById("d_ruleContent").textContent = current.dieule_noidung || "Chưa có điều lệ được công bố.";
        fillTeamSelect();
        renderTeamRegistrationState();
        modal.classList.remove("hidden");
        await loadTournamentRegistrations(current.idgiaidau);
    }

    tbody.addEventListener("click", (event) => {
        const button = event.target.closest("button[data-action='view']");
        if (button) {
            openDetail(button.dataset.id).catch((error) => ui.show(pageMessage, ui.errorsText(error), true));
        }
    });

    document.getElementById("d_close").addEventListener("click", () => modal.classList.add("hidden"));
    document.getElementById("d_cancel").addEventListener("click", () => modal.classList.add("hidden"));
    document.getElementById("btnRefresh").addEventListener("click", () => load().catch((error) => ui.show(pageMessage, ui.errorsText(error), true)));
    q.addEventListener("input", () => load().catch(() => {}));

    teamSelect.addEventListener("change", renderTeamRegistrationState);

    registerButton.addEventListener("click", async () => {
        ui.hideAlert(alertBox);
        if (!current) return;
        if (!teamSelect.value) {
            ui.showAlert(alertBox, "Vui lòng chọn đội bóng đăng ký.");
            return;
        }
        if (registrationForSelectedTeam()) {
            ui.showAlert(alertBox, "Đội bóng này đã có hồ sơ đăng ký trong giải đấu.");
            return;
        }

        try {
            const registeredTeamId = teamSelect.value;
            const result = await ui.requestJson(`${registrationsApi}`, {
                method: "POST",
                body: JSON.stringify({
                    idgiaidau: current.idgiaidau,
                    iddoibong: teamSelect.value,
                }),
            });
            ui.show(pageMessage, result.message || "Đã gửi đăng ký, chờ duyệt.");
            await loadTournamentRegistrations(current.idgiaidau);
            await load();
            fillTeamSelect(registeredTeamId);
            teamSelect.value = registeredTeamId;
            renderTeamRegistrationState();
        } catch (error) {
            ui.showAlert(alertBox, ui.errorsText(error));
        }
    });

    load().catch((error) => ui.show(pageMessage, ui.errorsText(error), true));
})();
