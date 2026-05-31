<section
    class="spectator-page spectator-schedule"
    data-schedule-api="<?= e(url('/api/public/schedule')) ?>"
>
    <header class="spectator-topbar">
        <div>
            <h1>Lịch thi đấu</h1>
            <p class="sub">Các trận đấu thuộc giải đấu đã công bố.</p>
        </div>
    </header>

    <section id="empty" class="empty hidden">
        Chưa có lịch thi đấu được công bố
    </section>

    <div class="table-wrap">
        <table class="spectator-table" id="scheduleTable">
            <thead>
                <tr>
                    <th>Ngày & Giờ</th>
                    <th>Giải đấu</th>
                    <th>Trận đấu</th>
                    <th>Địa điểm</th>
                    <th>Vòng</th>
                </tr>
            </thead>
            <tbody id="tbody">
                <tr><td colspan="5" class="empty">Đang tải dữ liệu...</td></tr>
            </tbody>
        </table>
    </div>
</section>
