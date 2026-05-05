const root = document.querySelector(".organizer-tournaments");
const tournamentsApi = root?.dataset.tournamentsApi || "/api/organizer/tournaments";

let tournaments = [];
let editingId = null;
let editingTournament = null;
let currentTournamentId = null;
let rejectingRegistrationId = null;
let searchTimer = null;
let registrationSearchTimer = null;

const tbody = document.getElementById("tbody");
const q = document.getElementById("q");
const statusFilter = document.getElementById("statusFilter");
const regFilter = document.getElementById("regFilter");
const fromDate = document.getElementById("fromDate");
const toDate = document.getElementById("toDate");
const btnRefresh = document.getElementById("btnRefresh");
const btnCreate = document.getElementById("btnCreate");
const pageMessage = document.getElementById("pageMessage");

const tournamentModal = document.getElementById("tournamentModal");
const regModal = document.getElementById("regModal");
const rejectModal = document.getElementById("rejectModal");

const fields = {
    title: document.getElementById("modalTitle"),
    name: document.getElementById("m_name"),
    start: document.getElementById("m_start"),
    end: document.getElementById("m_end"),
    place: document.getElementById("m_place"),
    size: document.getElementById("m_size"),
    image: document.getElementById("m_image"),
    desc: document.getElementById("m_desc"),
    ruleTitle: document.getElementById("m_rule_title"),
    ruleContent: document.getElementById("m_rule_content"),
    alert: document.getElementById("m_alert"),
    regTitle: document.getElementById("r_tourName"),
    regStatus: document.getElementById("r_status"),
    regSearch: document.getElementById("r_q"),
    regTable: document.getElementById("r_tbody"),
    rejectInfo: document.getElementById("rej_info"),
    rejectReason: document.getElementById("rej_reason"),
    rejectAlert: document.getElementById("rej_alert"),
};

const buttons = {
    modalClose: document.getElementById("m_close"),
    modalCancel: document.getElementById("m_cancel"),
    modalSave: document.getElementById("m_save"),
    regClose: document.getElementById("r_close"),
    regCloseBottom: document.getElementById("r_closeBtn"),
    rejectClose: document.getElementById("rej_close"),
    rejectCancel: document.getElementById("rej_cancel"),
    rejectConfirm: document.getElementById("rej_confirm"),
};

const tournamentStatusLabels = {
    CHUA_CONG_BO: "Chưa công bố",
    DA_CONG_BO: "Đã công bố",
    DANG_DIEN_RA: "Đang diễn ra",
    DA_KET_THUC: "Đã kết thúc",
    DA_HUY: "Đã hủy",
};

const registrationWindowLabels = {
    CHUA_MO: "Chưa mở",
    DANG_MO: "Đang mở",
    DA_DONG: "Đã đóng",
};

const registrationStatusLabels = {
    CHO_DUYET: "Chờ duyệt",
    DA_DUYET: "Đã duyệt",
    TU_CHOI: "Từ chối",
    DA_HUY: "Đã hủy",
};

function tournamentId(item) {
    return Number(item.idgiaidau || item.id);
}

function registrationId(item) {
    return Number(item.iddangky || item.id);
}

function escapeHtml(value) {
    return String(value ?? "")
        .replaceAll("&", "&amp;")
        .replaceAll("<", "&lt;")
        .replaceAll(">", "&gt;")
        .replaceAll('"', "&quot;")
        .replaceAll("'", "&#039;");
}

function setPageMessage(message, success = false) {
    pageMessage.textContent = message || "";
    pageMessage.classList.toggle("success", success);
}

function showAlert(element, message) {
    element.textContent = message;
    element.classList.remove("hidden");
}

function hideAlert(element) {
    element.textContent = "";
    element.classList.add("hidden");
}

function statusClass(status) {
    if (status === "DA_CONG_BO") {
        return "pub";
    }

    if (status === "DANG_DIEN_RA") {
        return "run";
    }

    if (status === "DA_KET_THUC") {
        return "end";
    }

    if (status === "DA_HUY") {
        return "cancel";
    }

    return "draft";
}

function regWindowClass(status) {
    if (status === "DANG_MO") {
        return "reg-on";
    }

    if (status === "DA_DONG") {
        return "reg-closed";
    }

    return "reg-off";
}

function registrationClass(status) {
    if (status === "DA_DUYET") {
        return "approved";
    }

    if (status === "TU_CHOI" || status === "DA_HUY") {
        return "rejected";
    }

    return "pending";
}

async function apiRequest(url, options = {}) {
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
        const details = payload.errors ? Object.values(payload.errors).join(" ") : "";
        throw new Error([payload.message, details].filter(Boolean).join(" ") || "Yêu cầu không thành công.");
    }

    return payload;
}

function buildTournamentUrl() {
    const params = new URLSearchParams();

    if (q.value.trim() !== "") {
        params.set("q", q.value.trim());
    }

    if (statusFilter.value !== "") {
        params.set("status", statusFilter.value);
    }

    if (regFilter.value !== "") {
        params.set("registration_status", regFilter.value);
    }

    if (fromDate.value !== "") {
        params.set("from", fromDate.value);
    }

    if (toDate.value !== "") {
        params.set("to", toDate.value);
    }

    const query = params.toString();

    return query === "" ? tournamentsApi : `${tournamentsApi}?${query}`;
}

async function loadTournaments() {
    tbody.innerHTML = '<tr><td colspan="8" class="empty">Đang tải dữ liệu...</td></tr>';
    setPageMessage("");

    try {
        const payload = await apiRequest(buildTournamentUrl());
        tournaments = payload.data || [];
        renderTournaments();
    } catch (error) {
        tournaments = [];
        renderTournaments();
        setPageMessage(error.message);
    }
}

function renderTournaments() {
    if (tournaments.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8" class="empty">Không có giải đấu phù hợp.</td></tr>';
        return;
    }

    tbody.innerHTML = tournaments.map((item) => {
        const id = tournamentId(item);
        const status = item.trangthai || "";
        const regStatus = item.trangthaidangky || "";
        const approved = Number(item.dangky_da_duyet || 0);
        const pending = Number(item.dangky_cho_duyet || 0);

        return `
            <tr>
                <td>${id}</td>
                <td>
                    <strong>${escapeHtml(item.tengiaidau)}</strong>
                    <span class="truncate" title="${escapeHtml(item.mota || "")}">${escapeHtml(item.mota || "")}</span>
                </td>
                <td>${escapeHtml(item.thoigianbatdau)} - ${escapeHtml(item.thoigianketthuc)}</td>
                <td><span class="truncate" title="${escapeHtml(item.diadiem)}">${escapeHtml(item.diadiem)}</span></td>
                <td>${Number(item.quymo || 0)}<br><span class="sub">Duyệt: ${approved}, chờ: ${pending}</span></td>
                <td><span class="badge ${statusClass(status)}">${escapeHtml(tournamentStatusLabels[status] || status)}</span></td>
                <td><span class="badge ${regWindowClass(regStatus)}">${escapeHtml(registrationWindowLabels[regStatus] || regStatus)}</span></td>
                <td>${rowActions(item)}</td>
            </tr>
        `;
    }).join("");
}

function rowActions(item) {
    const id = tournamentId(item);
    const status = item.trangthai || "";
    const regStatus = item.trangthaidangky || "";
    const canEdit = status === "CHUA_CONG_BO";
    const canPublish = status === "CHUA_CONG_BO";
    const canOpenReg = status === "DA_CONG_BO" && (regStatus === "CHUA_MO" || regStatus === "DA_DONG");
    const canCloseReg = status === "DA_CONG_BO" && regStatus === "DANG_MO";

    return `
        <div class="row-actions">
            <button class="btn" type="button" data-action="registrations" data-id="${id}">Đăng ký</button>
            ${canPublish ? `<button class="btn primary" type="button" data-action="publish" data-id="${id}">Công bố</button>` : ""}
            ${canOpenReg ? `<button class="btn" type="button" data-action="open-reg" data-id="${id}">Mở ĐK</button>` : ""}
            ${canCloseReg ? `<button class="btn" type="button" data-action="close-reg" data-id="${id}">Đóng ĐK</button>` : ""}
            ${canEdit ? `<button class="btn" type="button" data-action="edit" data-id="${id}">Sửa</button>` : ""}
            ${canEdit ? `<button class="btn danger" type="button" data-action="delete" data-id="${id}">Xóa</button>` : ""}
        </div>
    `;
}

function findTournament(id) {
    return tournaments.find((item) => tournamentId(item) === Number(id)) || null;
}

async function fetchTournament(id) {
    const payload = await apiRequest(`${tournamentsApi}/${id}`);
    return payload.data;
}

function openTournamentModal(mode, item = null) {
    hideAlert(fields.alert);
    editingId = null;
    editingTournament = item;
    fields.title.textContent = "Tạo giải đấu";
    fields.name.value = "";
    fields.start.value = "";
    fields.end.value = "";
    fields.place.value = "";
    fields.size.value = "8";
    fields.image.value = "";
    fields.desc.value = "";
    fields.ruleTitle.value = "Điều lệ giải đấu";
    fields.ruleContent.value = "";

    if (mode === "edit" && item) {
        const rules = Array.isArray(item.dieule) ? item.dieule : [];
        const firstRule = rules[0] || {};

        editingId = tournamentId(item);
        fields.title.textContent = "Sửa giải đấu (chưa công bố)";
        fields.name.value = item.tengiaidau || "";
        fields.start.value = item.thoigianbatdau || "";
        fields.end.value = item.thoigianketthuc || "";
        fields.place.value = item.diadiem || "";
        fields.size.value = item.quymo || "8";
        fields.image.value = item.hinhanh || "";
        fields.desc.value = item.mota || "";
        fields.ruleTitle.value = firstRule.tieude || "Điều lệ giải đấu";
        fields.ruleContent.value = firstRule.noidung || "";
    }

    tournamentModal.classList.remove("hidden");
    tournamentModal.setAttribute("aria-hidden", "false");
    fields.name.focus();
}

function closeTournamentModal() {
    tournamentModal.classList.add("hidden");
    tournamentModal.setAttribute("aria-hidden", "true");
    editingId = null;
    editingTournament = null;
    hideAlert(fields.alert);
}

function collectTournamentPayload() {
    return {
        tengiaidau: fields.name.value.trim(),
        thoigianbatdau: fields.start.value,
        thoigianketthuc: fields.end.value,
        diadiem: fields.place.value.trim(),
        quymo: fields.size.value,
        hinhanh: fields.image.value.trim() || null,
        mota: fields.desc.value.trim() || null,
        tieude_dieule: fields.ruleTitle.value.trim() || "Điều lệ giải đấu",
        dieule: fields.ruleContent.value.trim(),
    };
}

function validateTournamentPayload(payload) {
    if (payload.tengiaidau === "" || payload.diadiem === "") {
        return "Vui lòng nhập đầy đủ tên giải đấu và địa điểm.";
    }

    if (payload.thoigianbatdau === "" || payload.thoigianketthuc === "") {
        return "Vui lòng nhập ngày bắt đầu và ngày kết thúc.";
    }

    if (payload.thoigianketthuc < payload.thoigianbatdau) {
        return "Ngày kết thúc phải lớn hơn hoặc bằng ngày bắt đầu.";
    }

    if (!Number.isInteger(Number(payload.quymo)) || Number(payload.quymo) <= 0) {
        return "Quy mô phải là số nguyên lớn hơn 0.";
    }

    if (payload.dieule === "") {
        return "Vui lòng nhập nội dung điều lệ.";
    }

    return "";
}

async function saveTournament() {
    const payload = collectTournamentPayload();
    const validation = validateTournamentPayload(payload);

    hideAlert(fields.alert);

    if (validation !== "") {
        showAlert(fields.alert, validation);
        return;
    }

    buttons.modalSave.disabled = true;

    try {
        if (editingId) {
            await apiRequest(`${tournamentsApi}/${editingId}`, {
                method: "PATCH",
                body: JSON.stringify(payload),
            });
            setPageMessage("Cập nhật giải đấu thành công.", true);
        } else {
            await apiRequest(tournamentsApi, {
                method: "POST",
                body: JSON.stringify(payload),
            });
            setPageMessage("Tạo giải đấu thành công.", true);
        }

        closeTournamentModal();
        await loadTournaments();
    } catch (error) {
        showAlert(fields.alert, error.message);
    } finally {
        buttons.modalSave.disabled = false;
    }
}

async function publishTournament(id) {
    if (!window.confirm("Công bố giải đấu? Sau khi công bố sẽ hạn chế sửa.")) {
        return;
    }

    await runTournamentAction(`${tournamentsApi}/${id}/publish`, "Công bố giải đấu thành công.");
}

async function deleteTournament(id) {
    if (!window.confirm("Xóa giải đấu chưa công bố này?")) {
        return;
    }

    await runTournamentAction(`${tournamentsApi}/${id}`, "Xóa giải đấu thành công.", { method: "DELETE" });
}

async function openRegistrationWindow(id) {
    if (!window.confirm("Mở đăng ký giải đấu?")) {
        return;
    }

    await runTournamentAction(`${tournamentsApi}/${id}/registrations/open`, "Mở đăng ký giải đấu thành công.");
}

async function closeRegistrationWindow(id) {
    if (!window.confirm("Đóng đăng ký giải đấu?")) {
        return;
    }

    await runTournamentAction(`${tournamentsApi}/${id}/registrations/close`, "Đóng đăng ký giải đấu thành công.");
}

async function runTournamentAction(url, successMessage, options = {}) {
    setPageMessage("");

    try {
        await apiRequest(url, {
            method: "POST",
            body: JSON.stringify({}),
            ...options,
        });
        setPageMessage(successMessage, true);
        await loadTournaments();
    } catch (error) {
        setPageMessage(error.message);
    }
}

async function openRegistrations(id) {
    const item = findTournament(id);

    currentTournamentId = Number(id);
    fields.regTitle.textContent = item
        ? `${item.tengiaidau} - Trạng thái ĐK: ${registrationWindowLabels[item.trangthaidangky] || item.trangthaidangky}`
        : `Giải đấu #${id}`;
    fields.regStatus.value = "";
    fields.regSearch.value = "";
    regModal.classList.remove("hidden");
    regModal.setAttribute("aria-hidden", "false");
    await loadRegistrations();
}

function closeRegistrations() {
    regModal.classList.add("hidden");
    regModal.setAttribute("aria-hidden", "true");
    currentTournamentId = null;
    fields.regTable.innerHTML = "";
}

function buildRegistrationUrl() {
    const params = new URLSearchParams();

    if (fields.regStatus.value !== "") {
        params.set("status", fields.regStatus.value);
    }

    if (fields.regSearch.value.trim() !== "") {
        params.set("q", fields.regSearch.value.trim());
    }

    const query = params.toString();
    const base = `${tournamentsApi}/${currentTournamentId}/registrations`;

    return query === "" ? base : `${base}?${query}`;
}

async function loadRegistrations() {
    if (!currentTournamentId) {
        return;
    }

    fields.regTable.innerHTML = '<tr><td colspan="7" class="empty">Đang tải dữ liệu...</td></tr>';

    try {
        const payload = await apiRequest(buildRegistrationUrl());
        renderRegistrations(payload.data || []);
    } catch (error) {
        fields.regTable.innerHTML = `<tr><td colspan="7" class="empty">${escapeHtml(error.message)}</td></tr>`;
    }
}

function renderRegistrations(registrations) {
    if (registrations.length === 0) {
        fields.regTable.innerHTML = '<tr><td colspan="7" class="empty">Không có đăng ký phù hợp.</td></tr>';
        return;
    }

    fields.regTable.innerHTML = registrations.map((item) => {
        const id = registrationId(item);
        const status = item.trangthai || "";
        const actionable = status === "CHO_DUYET";

        return `
            <tr>
                <td>${id}</td>
                <td>
                    <strong>${escapeHtml(item.tendoibong)}</strong>
                    <span class="sub">${escapeHtml(item.doibong_diaphuong || "")}</span>
                </td>
                <td>
                    ${escapeHtml(item.huanluyenvien_hoten || item.huanluyenvien_username || "")}
                    <span class="sub">${escapeHtml(item.huanluyenvien_email || "")}</span>
                </td>
                <td>${escapeHtml(item.ngaydangky)}</td>
                <td><span class="badge ${registrationClass(status)}">${escapeHtml(registrationStatusLabels[status] || status)}</span></td>
                <td><span class="truncate" title="${escapeHtml(item.lydotuchoi || "")}">${escapeHtml(item.lydotuchoi || "")}</span></td>
                <td>
                    <div class="row-actions">
                        <button class="btn primary" type="button" data-action="approve-reg" data-id="${id}" ${actionable ? "" : "disabled"}>Duyệt</button>
                        <button class="btn danger" type="button" data-action="reject-reg" data-id="${id}" data-team="${escapeHtml(item.tendoibong)}" ${actionable ? "" : "disabled"}>Từ chối</button>
                    </div>
                </td>
            </tr>
        `;
    }).join("");
}

async function approveRegistration(id) {
    try {
        await apiRequest(`${tournamentsApi}/${currentTournamentId}/registrations/${id}/approve`, {
            method: "POST",
            body: JSON.stringify({}),
        });
        setPageMessage("Duyệt đăng ký thành công.", true);
        await loadRegistrations();
        await loadTournaments();
    } catch (error) {
        setPageMessage(error.message);
    }
}

function openRejectRegistration(id, teamName) {
    rejectingRegistrationId = Number(id);
    fields.rejectInfo.textContent = `ĐK #${id} - Đội: ${teamName || ""}`;
    fields.rejectReason.value = "";
    hideAlert(fields.rejectAlert);
    rejectModal.classList.remove("hidden");
    rejectModal.setAttribute("aria-hidden", "false");
    fields.rejectReason.focus();
}

function closeRejectRegistration() {
    rejectModal.classList.add("hidden");
    rejectModal.setAttribute("aria-hidden", "true");
    rejectingRegistrationId = null;
    hideAlert(fields.rejectAlert);
}

async function rejectRegistration() {
    const reason = fields.rejectReason.value.trim();

    if (reason === "") {
        showAlert(fields.rejectAlert, "Vui lòng nhập lý do từ chối.");
        return;
    }

    buttons.rejectConfirm.disabled = true;

    try {
        await apiRequest(`${tournamentsApi}/${currentTournamentId}/registrations/${rejectingRegistrationId}/reject`, {
            method: "POST",
            body: JSON.stringify({ lydotuchoi: reason }),
        });
        closeRejectRegistration();
        setPageMessage("Từ chối đăng ký thành công.", true);
        await loadRegistrations();
        await loadTournaments();
    } catch (error) {
        showAlert(fields.rejectAlert, error.message);
    } finally {
        buttons.rejectConfirm.disabled = false;
    }
}

tbody.addEventListener("click", async (event) => {
    const button = event.target.closest("button[data-action]");

    if (!button) {
        return;
    }

    const id = Number(button.dataset.id);
    const action = button.dataset.action;

    if (action === "registrations") {
        await openRegistrations(id);
        return;
    }

    if (action === "publish") {
        await publishTournament(id);
        return;
    }

    if (action === "open-reg") {
        await openRegistrationWindow(id);
        return;
    }

    if (action === "close-reg") {
        await closeRegistrationWindow(id);
        return;
    }

    if (action === "delete") {
        await deleteTournament(id);
        return;
    }

    if (action === "edit") {
        try {
            const item = await fetchTournament(id);
            openTournamentModal("edit", item);
        } catch (error) {
            setPageMessage(error.message);
        }
    }
});

fields.regTable.addEventListener("click", async (event) => {
    const button = event.target.closest("button[data-action]");

    if (!button || button.disabled) {
        return;
    }

    const id = Number(button.dataset.id);

    if (button.dataset.action === "approve-reg") {
        await approveRegistration(id);
        return;
    }

    if (button.dataset.action === "reject-reg") {
        openRejectRegistration(id, button.dataset.team || "");
    }
});

btnCreate.addEventListener("click", () => openTournamentModal("create"));
buttons.modalClose.addEventListener("click", closeTournamentModal);
buttons.modalCancel.addEventListener("click", closeTournamentModal);
buttons.modalSave.addEventListener("click", saveTournament);
buttons.regClose.addEventListener("click", closeRegistrations);
buttons.regCloseBottom.addEventListener("click", closeRegistrations);
buttons.rejectClose.addEventListener("click", closeRejectRegistration);
buttons.rejectCancel.addEventListener("click", closeRejectRegistration);
buttons.rejectConfirm.addEventListener("click", rejectRegistration);
btnRefresh.addEventListener("click", loadTournaments);

q.addEventListener("input", () => {
    clearTimeout(searchTimer);
    searchTimer = setTimeout(loadTournaments, 250);
});
statusFilter.addEventListener("change", loadTournaments);
regFilter.addEventListener("change", loadTournaments);
fromDate.addEventListener("change", loadTournaments);
toDate.addEventListener("change", loadTournaments);

fields.regStatus.addEventListener("change", loadRegistrations);
fields.regSearch.addEventListener("input", () => {
    clearTimeout(registrationSearchTimer);
    registrationSearchTimer = setTimeout(loadRegistrations, 250);
});

for (const modal of [tournamentModal, regModal, rejectModal]) {
    modal.addEventListener("click", (event) => {
        if (event.target !== modal) {
            return;
        }

        if (modal === tournamentModal) {
            closeTournamentModal();
        } else if (modal === regModal) {
            closeRegistrations();
        } else {
            closeRejectRegistration();
        }
    });
}

document.addEventListener("keydown", (event) => {
    if (event.key !== "Escape") {
        return;
    }

    if (!rejectModal.classList.contains("hidden")) {
        closeRejectRegistration();
        return;
    }

    if (!regModal.classList.contains("hidden")) {
        closeRegistrations();
        return;
    }

    if (!tournamentModal.classList.contains("hidden")) {
        closeTournamentModal();
    }
});

loadTournaments();
