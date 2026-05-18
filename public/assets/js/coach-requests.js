(function () {
    const root = document.querySelector(".coach-requests");
    if (!root) return;

    const ui = window.CoachUI;
    const requestsApi = root.dataset.requestsApi || "/api/coach/athlete-change-requests";
    const tbody = document.getElementById("tbody");
    const empty = document.getElementById("empty");
    const table = document.getElementById("requestTable");
    const pageMessage = document.getElementById("pageMessage");
    const modal = document.getElementById("detailModal");
    const alertBox = document.getElementById("m_alert");

    let requests = [];
    let current = null;

    function render() {
        if (requests.length === 0) {
            table.classList.add("hidden");
            empty.classList.remove("hidden");
            return;
        }

        table.classList.remove("hidden");
        empty.classList.add("hidden");
        tbody.innerHTML = requests.map((request) => {
            const [badgeClass, label] = ui.badge(request.trangthai);
            return `
                <tr>
                    <td>${ui.escapeHtml(request.idyeucaucapnhat)}</td>
                    <td>${ui.escapeHtml(request.hoten || request.username || "")}</td>
                    <td>${ui.escapeHtml(request.banglienquan)}</td>
                    <td>${ui.escapeHtml(request.truongcapnhat)}</td>
                    <td>${ui.escapeHtml(request.giatricu ?? "")}</td>
                    <td>${ui.escapeHtml(request.giatrimoi ?? "")}</td>
                    <td>${ui.escapeHtml(request.ngaygui || "")}</td>
                    <td><span class="badge ${badgeClass}">${ui.escapeHtml(label)}</span></td>
                    <td><button class="btn" type="button" data-id="${ui.escapeHtml(request.idyeucaucapnhat)}">Xem chi tiết</button></td>
                </tr>
            `;
        }).join("");
    }

    async function load() {
        const params = {
            q: document.getElementById("q").value.trim(),
            status: document.getElementById("statusFilter").value,
            from: document.getElementById("fromDate").value,
            to: document.getElementById("toDate").value,
        };
        const payload = await ui.requestJson(ui.apiUrl(requestsApi, params));
        requests = payload.data || [];
        render();
    }

    function openDetail(id) {
        current = requests.find((request) => String(request.idyeucaucapnhat) === String(id));
        if (!current) return;
        ui.hideAlert(alertBox);
        document.getElementById("oldInfo").textContent = JSON.stringify({
            van_dong_vien: current.hoten,
            bang: current.banglienquan,
            truong: current.truongcapnhat,
            gia_tri_cu: current.giatricu,
            ly_do: current.lydo,
        }, null, 2);
        document.getElementById("newInfo").textContent = JSON.stringify({
            gia_tri_moi: current.giatrimoi,
            trang_thai: current.trangthai,
            ngay_gui: current.ngaygui,
            ngay_xu_ly: current.ngayxuly,
        }, null, 2);
        document.getElementById("m_note").value = "";
        const actionable = current.trangthai === "CHO_DUYET";
        document.getElementById("btnApprove").disabled = !actionable;
        document.getElementById("btnReject").disabled = !actionable;
        modal.classList.remove("hidden");
    }

    tbody.addEventListener("click", (event) => {
        const button = event.target.closest("button[data-id]");
        if (button) openDetail(button.dataset.id);
    });
    document.getElementById("m_close").addEventListener("click", () => modal.classList.add("hidden"));
    document.getElementById("btnRefresh").addEventListener("click", () => load().catch((error) => ui.show(pageMessage, ui.errorsText(error), true)));
    ["q", "statusFilter", "fromDate", "toDate"].forEach((id) => {
        const element = document.getElementById(id);
        element.addEventListener("change", () => load().catch(() => {}));
        element.addEventListener("input", () => load().catch(() => {}));
    });

    document.getElementById("btnApprove").addEventListener("click", async () => {
        if (!current) return;
        try {
            const result = await ui.requestJson(`${requestsApi}/${current.idyeucaucapnhat}/approve`, {
                method: "POST",
                body: JSON.stringify({ note: "HLV duyệt thay đổi thông tin VĐV" }),
            });
            modal.classList.add("hidden");
            ui.show(pageMessage, result.message || "Đã duyệt yêu cầu.");
            await load();
        } catch (error) {
            ui.showAlert(alertBox, ui.errorsText(error));
        }
    });

    document.getElementById("btnReject").addEventListener("click", async () => {
        if (!current) return;
        const note = document.getElementById("m_note").value.trim();
        if (!note) {
            ui.showAlert(alertBox, "Vui lòng nhập ghi chú khi từ chối.");
            return;
        }
        try {
            const result = await ui.requestJson(`${requestsApi}/${current.idyeucaucapnhat}/reject`, {
                method: "POST",
                body: JSON.stringify({ note }),
            });
            modal.classList.add("hidden");
            ui.show(pageMessage, result.message || "Đã từ chối yêu cầu.");
            await load();
        } catch (error) {
            ui.showAlert(alertBox, ui.errorsText(error));
        }
    });

    load().catch((error) => ui.show(pageMessage, ui.errorsText(error), true));
})();
