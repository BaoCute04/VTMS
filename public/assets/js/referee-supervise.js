(function () {
    const root = document.querySelector(".referee-supervise");

    if (!root) {
        return;
    }

    const supervisionApi = (root.dataset.supervisionApi || "/api/trongtai/matches").replace(/\/+$/, "");
    const assignmentsApi = (root.dataset.assignmentsApi || "/api/trongtai/assignments").replace(/\/+$/, "");

    const matchTitle = document.getElementById("matchTitle");
    const matchSub = document.getElementById("matchSub");
    const matchState = document.getElementById("matchState");
    const mMatchId = document.getElementById("m_matchId");
    const mTournament = document.getElementById("m_tournament");
    const mVenue = document.getElementById("m_venue");
    const mRound = document.getElementById("m_round");
    const mStart = document.getElementById("m_start");
    const mEnd = document.getElementById("m_end");
    const pageAlert = document.getElementById("pageAlert");

    const btnJoin = document.getElementById("btnJoin");
    const btnPickRefs = document.getElementById("btnPickRefs");
    const btnStart = document.getElementById("btnStart");
    const btnPause = document.getElementById("btnPause");
    const btnResume = document.getElementById("btnResume");
    const btnEnd = document.getElementById("btnEnd");

    const setsEl = document.getElementById("sets");
    const btnAddSet = document.getElementById("btnAddSet");
    const btnRemoveSet = document.getElementById("btnRemoveSet");
    const setScore = document.getElementById("setScore");
    const winner = document.getElementById("winner");
    const resultNote = document.getElementById("resultNote");
    const btnSaveResult = document.getElementById("btnSaveResult");
    const resultState = document.getElementById("resultState");

    const refsModal = document.getElementById("refsModal");
    const rClose = document.getElementById("r_close");
    const rCancel = document.getElementById("r_cancel");
    const rConfirm = document.getElementById("r_confirm");
    const rTbody = document.getElementById("r_tbody");
    const rAlert = document.getElementById("r_alert");

    const assignmentStatusMap = {
        CHO_XAC_NHAN: ["wait", "Chờ xác nhận"],
        DA_XAC_NHAN: ["ok", "Đã xác nhận"],
        TU_CHOI: ["bad", "Từ chối"],
        DA_HUY: ["gray", "Đã hủy"],
    };

    const matchStatusMap = {
        CHUA_DIEN_RA: "Chưa diễn ra",
        SAP_DIEN_RA: "Sắp diễn ra",
        DANG_DIEN_RA: "Đang diễn ra",
        TAM_DUNG: "Tạm dừng",
        DA_KET_THUC: "Đã kết thúc",
        DA_HUY: "Đã hủy",
    };

    const roleMap = {
        TRONG_TAI_CHINH: "Trọng tài chính",
        TRONG_TAI_PHU: "Trọng tài phụ",
        GIAM_SAT: "Giám sát",
    };

    const query = new URLSearchParams(window.location.search);
    const matchId = query.get("matchId") ? Number(query.get("matchId")) : null;
    const initialAssignmentId = query.get("assignmentId") ? Number(query.get("assignmentId")) : null;

    let match = null;
    let assignedRefs = [];
    let confirmedParticipants = new Set();
    let sets = [{ a: 0, b: 0 }, { a: 0, b: 0 }, { a: 0, b: 0 }];

    function escapeHtml(value) {
        return String(value ?? "")
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }

    function responseData(payload) {
        return payload && Object.prototype.hasOwnProperty.call(payload, "data") ? payload.data : null;
    }

    async function requestJson(url, options = {}) {
        const response = await fetch(url, {
            credentials: "same-origin",
            headers: {
                Accept: "application/json",
                "Content-Type": "application/json",
                ...(options.headers || {}),
            },
            ...options,
        });
        const payload = await response.json().catch(() => ({}));

        if (!response.ok || payload.success === false) {
            const detail = payload.errors
                ? Object.values(payload.errors).filter(Boolean).join(" ")
                : "";
            const message = [payload.message, detail].filter(Boolean).join(" ");
            const error = new Error(message || "Yêu cầu không thành công.");
            error.status = response.status;
            error.payload = payload;
            throw error;
        }

        return payload;
    }

    function formatDateTime(value) {
        if (!value) {
            return "";
        }

        return String(value).replace("T", " ").slice(0, 19);
    }

    function showPage(message, ok = false) {
        pageAlert.textContent = message || "";
        pageAlert.classList.toggle("hidden", !message);
        pageAlert.classList.toggle("is-ok", ok);
    }

    function showRefs(message) {
        rAlert.textContent = message || "";
        rAlert.classList.toggle("hidden", !message);
    }

    function assignmentBadge(status) {
        return assignmentStatusMap[status] || ["gray", status || "-"];
    }

    function assignmentStatusLabel(status) {
        return assignmentStatusMap[status]?.[1] || status || "-";
    }

    function roleLabel(role) {
        return roleMap[role] || role || "-";
    }

    function matchStatusLabel(status) {
        return matchStatusMap[status] || status || "-";
    }

    function refereeDisplayName(referee) {
        const name = String(referee.hoten || "").trim();
        const username = String(referee.username || "").trim();

        if (name && username) {
            return `${name} (${username})`;
        }

        return name || username || `#${referee.idtrongtai || ""}`;
    }

    function matchEndpoint(suffix = "supervision") {
        return `${supervisionApi}/${encodeURIComponent(matchId)}/${suffix}`;
    }

    function currentAssignment() {
        return match?.phancong_cua_toi || null;
    }

    function currentAssignmentId() {
        return currentAssignment()?.idphancong || initialAssignmentId || null;
    }

    function teamOneName() {
        return match?.doi1?.tendoibong || "-";
    }

    function teamTwoName() {
        return match?.doi2?.tendoibong || "-";
    }

    function setButtonsLoading(loading) {
        [btnJoin, btnPickRefs, btnStart, btnPause, btnResume, btnEnd, btnSaveResult, rConfirm].forEach((button) => {
            button.dataset.loading = loading ? "1" : "";
            button.disabled = loading;
        });
    }

    function refreshHeader() {
        if (!match) {
            return;
        }

        matchTitle.textContent = `#${match.idtrandau} • ${teamOneName()} vs ${teamTwoName()}`;
        matchSub.textContent = `${match.giaidau?.tengiaidau || ""} • ${match.sandau?.tensandau || ""} • ${formatDateTime(match.thoigianbatdau)}`;
        matchState.textContent = `Trạng thái: ${matchStatusLabel(match.trangthai)}`;
        mMatchId.value = match.idtrandau || "";
        mTournament.value = match.giaidau?.tengiaidau || "";
        mVenue.value = match.sandau?.tensandau || "";
        mRound.value = match.vongdau || "";
        mStart.value = formatDateTime(match.thoigianbatdau);
        mEnd.value = formatDateTime(match.thoigianketthuc);
    }

    function refreshButtons() {
        const assignment = currentAssignment();
        const assignmentStatus = assignment?.trangthai || "";
        const actions = match?.actions || {};
        const loadingButtons = root.querySelectorAll("[data-loading='1']");

        btnJoin.disabled = !(assignmentStatus === "CHO_XAC_NHAN");
        btnJoin.textContent = assignmentStatus === "DA_XAC_NHAN" ? "Đã xác nhận tham gia" : "Xác nhận tham gia trận đấu";
        btnPickRefs.disabled = !actions.confirm_participants;
        btnStart.disabled = !actions.start;
        btnPause.disabled = !actions.pause;
        btnResume.disabled = !actions.resume;
        btnEnd.disabled = !actions.finish;
        btnSaveResult.disabled = !actions.record_result;

        loadingButtons.forEach((button) => {
            button.disabled = true;
        });
    }

    function setsFromResult(result) {
        const resultSets = Array.isArray(result?.sets) ? result.sets : [];

        if (resultSets.length === 0) {
            return [{ a: 0, b: 0 }, { a: 0, b: 0 }, { a: 0, b: 0 }];
        }

        return resultSets.map((item) => ({
            a: Number(item.diemdoi1 || 0),
            b: Number(item.diemdoi2 || 0),
        }));
    }

    function computeSetWins() {
        let a = 0;
        let b = 0;

        for (const item of sets) {
            const one = Number(item.a || 0);
            const two = Number(item.b || 0);

            if (one > two) {
                a += 1;
            } else if (two > one) {
                b += 1;
            }
        }

        return { a, b };
    }

    function recalcResult() {
        const score = computeSetWins();
        setScore.value = `${score.a} - ${score.b}`;
        winner.value = score.a === score.b ? "Chưa xác định" : (score.a > score.b ? teamOneName() : teamTwoName());
        resultState.textContent = `Kết quả: ${setScore.value}`;
    }

    function renderSets() {
        setsEl.innerHTML = sets.map((item, index) => `
            <div class="set-row">
                <div class="tag">Set ${index + 1}</div>
                <input type="number" min="0" data-idx="${index}" data-side="a" value="${escapeHtml(item.a)}" placeholder="Điểm đội 1" />
                <input type="number" min="0" data-idx="${index}" data-side="b" value="${escapeHtml(item.b)}" placeholder="Điểm đội 2" />
            </div>
        `).join("");
        recalcResult();
    }

    function validateResult() {
        if (sets.length < 1 || sets.length > 5) {
            return "Danh sách điểm set phải có từ 1 đến 5 set.";
        }

        for (const [index, item] of sets.entries()) {
            const one = Number(item.a);
            const two = Number(item.b);

            if (!Number.isInteger(one) || !Number.isInteger(two) || one < 0 || two < 0) {
                return `Điểm set ${index + 1} phải là số nguyên không âm.`;
            }

            if (one === two) {
                return `Set ${index + 1} không được hòa.`;
            }
        }

        const score = computeSetWins();

        if (score.a === score.b) {
            return "Tỷ số set đang hòa. Vui lòng kiểm tra lại điểm từng set.";
        }

        return null;
    }

    function resultPayload() {
        return {
            sets: sets.map((item, index) => ({
                setthu: index + 1,
                diemdoi1: Number(item.a),
                diemdoi2: Number(item.b),
            })),
            note: resultNote.value.trim() || null,
        };
    }

    function renderRefsList() {
        if (assignedRefs.length === 0) {
            rTbody.innerHTML = '<tr><td colspan="5" class="empty">Chưa có trọng tài được phân công.</td></tr>';
            return;
        }

        rTbody.innerHTML = assignedRefs.map((referee) => {
            const id = Number(referee.idtrongtai);
            const [className, label] = assignmentBadge(referee.trangthai);
            const checked = confirmedParticipants.has(id) ? "checked" : "";
            const disabled = referee.trangthai === "DA_XAC_NHAN" ? "" : "disabled";

            return `
                <tr>
                    <td><input type="checkbox" data-id="${escapeHtml(id)}" ${checked} ${disabled} /></td>
                    <td>${escapeHtml(refereeDisplayName(referee))}</td>
                    <td>${escapeHtml(roleLabel(referee.vaitro))}</td>
                    <td><span class="badge ${className}">${escapeHtml(label)}</span></td>
                    <td>${escapeHtml(formatDateTime(referee.ngayphancong))}</td>
                </tr>
            `;
        }).join("");
    }

    function openRefsModal() {
        showRefs("");
        renderRefsList();
        refsModal.classList.remove("hidden");
    }

    function closeRefsModal() {
        refsModal.classList.add("hidden");
    }

    function applySupervision(data) {
        match = data;
        assignedRefs = Array.isArray(data?.trongtai_thamgia) ? data.trongtai_thamgia : [];
        confirmedParticipants = new Set(
            assignedRefs
                .filter((referee) => referee.xacnhanthamgia)
                .map((referee) => Number(referee.idtrongtai))
        );
        sets = setsFromResult(data?.ketqua);
        resultNote.value = "";
        refreshHeader();
        renderSets();
        refreshButtons();
    }

    async function loadSupervision() {
        if (!matchId) {
            showPage("Thiếu mã trận đấu. Vui lòng mở chức năng giám sát từ lịch phân công.");
            refreshButtons();
            return;
        }

        showPage("Đang tải dữ liệu giám sát...", true);

        try {
            const payload = await requestJson(matchEndpoint("supervision"));
            const data = responseData(payload);

            if (!data) {
                throw new Error("Không tìm thấy dữ liệu giám sát trận đấu.");
            }

            applySupervision(data);
            showPage("");
        } catch (error) {
            match = null;
            assignedRefs = [];
            refreshButtons();
            showPage(error.message || "Không thể tải dữ liệu giám sát.");
        }
    }

    async function runAction(endpoint, body = null, successMessage = "") {
        setButtonsLoading(true);
        showPage("");

        try {
            const payload = await requestJson(endpoint, {
                method: "POST",
                body: JSON.stringify(body || {}),
            });
            const data = responseData(payload);

            if (data) {
                applySupervision(data);
            } else {
                await loadSupervision();
            }

            showPage(successMessage || payload.message || "Cập nhật thành công.", true);
            return true;
        } catch (error) {
            showPage(error.message || "Không thể thực hiện thao tác.");
            refreshButtons();
            return false;
        } finally {
            setButtonsLoading(false);
            refreshButtons();
        }
    }

    btnJoin.addEventListener("click", async () => {
        const assignmentId = currentAssignmentId();

        if (!assignmentId) {
            showPage("Không tìm thấy mã phân công của trọng tài.");
            return;
        }

        await runAction(`${assignmentsApi}/${encodeURIComponent(assignmentId)}/confirm`, {}, "Đã xác nhận tham gia trận đấu.");
    });

    btnPickRefs.addEventListener("click", openRefsModal);
    rClose.addEventListener("click", closeRefsModal);
    rCancel.addEventListener("click", closeRefsModal);

    rTbody.addEventListener("change", (event) => {
        const input = event.target.closest("input[type='checkbox'][data-id]");

        if (!input) {
            return;
        }

        const id = Number(input.dataset.id);

        if (!id) {
            return;
        }

        if (input.checked) {
            confirmedParticipants.add(id);
        } else {
            confirmedParticipants.delete(id);
        }
    });

    rConfirm.addEventListener("click", async () => {
        showRefs("");

        if (confirmedParticipants.size === 0) {
            showRefs("Vui lòng chọn ít nhất 1 trọng tài tham gia.");
            return;
        }

        const ok = await runAction(matchEndpoint("participants/confirm"), {
            referee_ids: Array.from(confirmedParticipants),
        }, "Đã xác nhận tổ trọng tài tham gia.");

        if (ok) {
            closeRefsModal();
        }
    });

    btnStart.addEventListener("click", () => runAction(matchEndpoint("start"), {}, "Đã bắt đầu trận đấu."));
    btnPause.addEventListener("click", () => runAction(matchEndpoint("pause"), {}, "Đã tạm dừng trận đấu."));
    btnResume.addEventListener("click", () => runAction(matchEndpoint("resume"), {}, "Đã tiếp tục trận đấu."));

    btnSaveResult.addEventListener("click", async () => {
        const error = validateResult();

        if (error) {
            showPage(error);
            return;
        }

        await runAction(matchEndpoint("result"), resultPayload(), "Đã lưu kết quả trận đấu.");
    });

    btnEnd.addEventListener("click", async () => {
        const error = validateResult();

        if (error) {
            showPage(`Trước khi kết thúc, vui lòng nhập kết quả hợp lệ. ${error}`);
            return;
        }

        if (!window.confirm("Kết thúc trận đấu và ghi nhận kết quả hiện tại?")) {
            return;
        }

        await runAction(matchEndpoint("finish"), resultPayload(), "Đã kết thúc trận đấu.");
    });

    setsEl.addEventListener("input", (event) => {
        const input = event.target.closest("input[data-idx][data-side]");

        if (!input) {
            return;
        }

        const index = Number(input.dataset.idx);
        const side = input.dataset.side;

        if (!Number.isInteger(index) || !sets[index] || !["a", "b"].includes(side)) {
            return;
        }

        sets[index][side] = Number(input.value || 0);
        recalcResult();
    });

    btnAddSet.addEventListener("click", () => {
        if (sets.length >= 5) {
            return;
        }

        sets.push({ a: 0, b: 0 });
        renderSets();
    });

    btnRemoveSet.addEventListener("click", () => {
        if (sets.length <= 1) {
            return;
        }

        sets.pop();
        renderSets();
    });

    loadSupervision();
})();
