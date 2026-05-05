<?php

declare(strict_types=1);

namespace App\Backend\Models;

use App\Backend\Core\Model;
use Throwable;

final class Giaidau extends Model
{
    public function findOrganizerByAccountId(int $accountId): ?array
    {
        return $this->first(
            "SELECT
                btc.idbantochuc,
                btc.idnguoidung,
                btc.donvi,
                btc.chucvu,
                btc.trangthai,
                tk.idtaikhoan,
                tk.username,
                nd.hodem,
                nd.ten,
                TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) AS hoten
             FROM Bantochuc btc
             JOIN Nguoidung nd ON nd.idnguoidung = btc.idnguoidung
             JOIN Taikhoan tk ON tk.idtaikhoan = nd.idtaikhoan
             WHERE tk.idtaikhoan = :account_id
             LIMIT 1",
            ['account_id' => $accountId]
        );
    }

    public function existsByNameAndStartDate(string $name, string $startDate, ?int $excludeTournamentId = null): bool
    {
        $bindings = [
            'name' => $name,
            'start_date' => $startDate,
        ];

        $sql = "SELECT 1
             FROM Giaidau
             WHERE tengiaidau = :name
               AND thoigianbatdau = :start_date";

        if ($excludeTournamentId !== null) {
            $sql .= ' AND idgiaidau <> :exclude_tournament_id';
            $bindings['exclude_tournament_id'] = $excludeTournamentId;
        }

        $sql .= ' LIMIT 1';

        return $this->first(
            $sql,
            $bindings
        ) !== null;
    }

    public function listForOrganizer(int $organizerId, array $filters = []): array
    {
        $where = ['gd.idbantochuc = :organizer_id'];
        $bindings = ['organizer_id' => $organizerId];

        if (($filters['q'] ?? '') !== '') {
            $where[] = '(gd.tengiaidau LIKE :keyword OR gd.diadiem LIKE :keyword)';
            $bindings['keyword'] = '%' . $filters['q'] . '%';
        }

        if (($filters['status'] ?? '') !== '') {
            $where[] = 'gd.trangthai = :status';
            $bindings['status'] = $filters['status'];
        }

        if (($filters['registration_status'] ?? '') !== '') {
            $where[] = 'gd.trangthaidangky = :registration_status';
            $bindings['registration_status'] = $filters['registration_status'];
        }

        if (($filters['from'] ?? '') !== '') {
            $where[] = 'gd.thoigianbatdau >= :from_date';
            $bindings['from_date'] = $filters['from'];
        }

        if (($filters['to'] ?? '') !== '') {
            $where[] = 'gd.thoigianbatdau <= :to_date';
            $bindings['to_date'] = $filters['to'];
        }

        $statement = $this->db()->prepare(
            "SELECT
                gd.idgiaidau,
                gd.tengiaidau,
                gd.mota,
                gd.thoigianbatdau,
                gd.thoigianketthuc,
                gd.diadiem,
                gd.quymo,
                gd.hinhanh,
                gd.trangthai,
                gd.trangthaidangky,
                gd.idbantochuc,
                gd.ngaytao,
                gd.ngaycapnhat,
                COALESCE(reg.total_dangky, 0) AS total_dangky,
                COALESCE(reg.cho_duyet, 0) AS dangky_cho_duyet,
                COALESCE(reg.da_duyet, 0) AS dangky_da_duyet,
                COALESCE(reg.tu_choi, 0) AS dangky_tu_choi,
                COALESCE(reg.da_huy, 0) AS dangky_da_huy
             FROM Giaidau gd
             LEFT JOIN (
                SELECT
                    idgiaidau,
                    COUNT(*) AS total_dangky,
                    SUM(CASE WHEN trangthai = 'CHO_DUYET' THEN 1 ELSE 0 END) AS cho_duyet,
                    SUM(CASE WHEN trangthai = 'DA_DUYET' THEN 1 ELSE 0 END) AS da_duyet,
                    SUM(CASE WHEN trangthai = 'TU_CHOI' THEN 1 ELSE 0 END) AS tu_choi,
                    SUM(CASE WHEN trangthai = 'DA_HUY' THEN 1 ELSE 0 END) AS da_huy
                FROM Dangkygiaidau
                GROUP BY idgiaidau
             ) reg ON reg.idgiaidau = gd.idgiaidau
             WHERE " . implode(' AND ', $where) . "
             ORDER BY gd.ngaytao DESC, gd.idgiaidau DESC"
        );

        $statement->execute($bindings);

        return $statement->fetchAll();
    }

    public function createTournament(
        array $tournament,
        array $rules,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): int {
        $db = $this->db();

        try {
            $db->beginTransaction();

            $statement = $db->prepare(
                "INSERT INTO Giaidau
                    (tengiaidau, mota, thoigianbatdau, thoigianketthuc, diadiem, quymo, hinhanh, trangthai, trangthaidangky, idbantochuc)
                 VALUES
                    (:tengiaidau, :mota, :thoigianbatdau, :thoigianketthuc, :diadiem, :quymo, :hinhanh, 'CHUA_CONG_BO', 'CHUA_MO', :idbantochuc)"
            );

            $statement->execute([
                'tengiaidau' => $tournament['tengiaidau'],
                'mota' => $tournament['mota'],
                'thoigianbatdau' => $tournament['thoigianbatdau'],
                'thoigianketthuc' => $tournament['thoigianketthuc'],
                'diadiem' => $tournament['diadiem'],
                'quymo' => $tournament['quymo'],
                'hinhanh' => $tournament['hinhanh'],
                'idbantochuc' => $tournament['idbantochuc'],
            ]);

            $tournamentId = (int) $db->lastInsertId();

            $this->insertRules($tournamentId, $rules);
            $this->recordStatusHistory('GIAI_DAU', $tournamentId, null, 'CHUA_CONG_BO', 'Tao giai dau', $actorAccountId);
            $this->recordSystemLog($actorAccountId, 'Tao giai dau', 'Giaidau', $tournamentId, $ipAddress, $logNote);

            $db->commit();

            return $tournamentId;
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function updateTournament(
        int $tournamentId,
        array $tournament,
        ?array $rules,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): void {
        $db = $this->db();

        try {
            $db->beginTransaction();

            $this->updateTournamentFields($tournamentId, $tournament);

            if ($rules !== null) {
                $this->replaceRules($tournamentId, $rules);
            }

            $this->recordSystemLog($actorAccountId, 'Cap nhat giai dau', 'Giaidau', $tournamentId, $ipAddress, $logNote);

            $db->commit();
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function deleteTournament(
        int $tournamentId,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): void {
        $db = $this->db();

        try {
            $db->beginTransaction();

            $this->recordStatusHistory('GIAI_DAU', $tournamentId, 'CHUA_CONG_BO', 'DA_HUY', 'Xoa giai dau chua cong bo', $actorAccountId);
            $this->recordSystemLog($actorAccountId, 'Xoa giai dau', 'Giaidau', $tournamentId, $ipAddress, $logNote);

            $statement = $db->prepare(
                "DELETE FROM Giaidau
                 WHERE idgiaidau = :tournament_id
                   AND trangthai = 'CHUA_CONG_BO'"
            );

            $statement->execute(['tournament_id' => $tournamentId]);

            if ($statement->rowCount() !== 1) {
                throw new \RuntimeException('TOURNAMENT_NOT_DELETED');
            }

            $db->commit();
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function publishTournament(
        int $tournamentId,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): void {
        $db = $this->db();

        try {
            $db->beginTransaction();

            $statement = $db->prepare(
                "UPDATE Giaidau
                 SET trangthai = 'DA_CONG_BO',
                     ngaycapnhat = CURRENT_TIMESTAMP
                 WHERE idgiaidau = :tournament_id
                   AND trangthai = 'CHUA_CONG_BO'"
            );

            $statement->execute(['tournament_id' => $tournamentId]);

            if ($statement->rowCount() !== 1) {
                throw new \RuntimeException('TOURNAMENT_NOT_PUBLISHED');
            }

            $this->recordStatusHistory('GIAI_DAU', $tournamentId, 'CHUA_CONG_BO', 'DA_CONG_BO', 'Cong bo giai dau', $actorAccountId);
            $this->recordSystemLog($actorAccountId, 'Cong bo giai dau', 'Giaidau', $tournamentId, $ipAddress, $logNote);

            $db->commit();
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function updateRegistrationWindow(
        int $tournamentId,
        string $oldStatus,
        string $newStatus,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): void {
        $db = $this->db();
        $action = $newStatus === 'DANG_MO' ? 'Mo dang ky giai dau' : 'Dong dang ky giai dau';

        try {
            $db->beginTransaction();

            $statement = $db->prepare(
                "UPDATE Giaidau
                 SET trangthaidangky = :new_status,
                     ngaycapnhat = CURRENT_TIMESTAMP
                 WHERE idgiaidau = :tournament_id
                   AND trangthai = 'DA_CONG_BO'
                   AND trangthaidangky = :old_status"
            );

            $statement->execute([
                'new_status' => $newStatus,
                'tournament_id' => $tournamentId,
                'old_status' => $oldStatus,
            ]);

            if ($statement->rowCount() !== 1) {
                throw new \RuntimeException('REGISTRATION_WINDOW_NOT_UPDATED');
            }

            $this->recordStatusHistory('GIAI_DAU', $tournamentId, $oldStatus, $newStatus, $action, $actorAccountId);
            $this->recordSystemLog($actorAccountId, $action, 'Giaidau', $tournamentId, $ipAddress, $logNote);

            $db->commit();
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function registrationsForTournament(int $tournamentId, array $filters = []): array
    {
        $where = ['dk.idgiaidau = :tournament_id'];
        $bindings = ['tournament_id' => $tournamentId];

        if (($filters['status'] ?? '') !== '') {
            $where[] = 'dk.trangthai = :status';
            $bindings['status'] = $filters['status'];
        }

        if (($filters['q'] ?? '') !== '') {
            $where[] = "(db.tendoibong LIKE :keyword
                OR db.diaphuong LIKE :keyword
                OR CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, '')) LIKE :keyword)";
            $bindings['keyword'] = '%' . $filters['q'] . '%';
        }

        $statement = $this->db()->prepare(
            "SELECT
                dk.iddangky,
                dk.idgiaidau,
                dk.iddoibong,
                dk.idhuanluyenvien,
                dk.ngaydangky,
                dk.trangthai,
                dk.lydotuchoi,
                db.tendoibong,
                db.logo AS doibong_logo,
                db.diaphuong AS doibong_diaphuong,
                db.trangthai AS doibong_trangthai,
                hlv.bangcap AS huanluyenvien_bangcap,
                hlv.kinhnghiem AS huanluyenvien_kinhnghiem,
                hlv.trangthai AS huanluyenvien_trangthai,
                nd.idnguoidung AS huanluyenvien_idnguoidung,
                TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) AS huanluyenvien_hoten,
                tk.username AS huanluyenvien_username,
                tk.email AS huanluyenvien_email
             FROM Dangkygiaidau dk
             JOIN Doibong db ON db.iddoibong = dk.iddoibong
             JOIN Huanluyenvien hlv ON hlv.idhuanluyenvien = dk.idhuanluyenvien
             JOIN Nguoidung nd ON nd.idnguoidung = hlv.idnguoidung
             JOIN Taikhoan tk ON tk.idtaikhoan = nd.idtaikhoan
             WHERE " . implode(' AND ', $where) . "
             ORDER BY dk.ngaydangky DESC, dk.iddangky DESC"
        );

        $statement->execute($bindings);

        return $statement->fetchAll();
    }

    public function registrationStatsForTournament(int $tournamentId): array
    {
        $statement = $this->db()->prepare(
            "SELECT trangthai, COUNT(*) AS total
             FROM Dangkygiaidau
             WHERE idgiaidau = :tournament_id
             GROUP BY trangthai"
        );

        $statement->execute(['tournament_id' => $tournamentId]);

        $stats = [
            'CHO_DUYET' => 0,
            'DA_DUYET' => 0,
            'TU_CHOI' => 0,
            'DA_HUY' => 0,
        ];

        foreach ($statement->fetchAll() as $row) {
            $stats[(string) $row['trangthai']] = (int) $row['total'];
        }

        return $stats;
    }

    public function findRegistration(int $tournamentId, int $registrationId): ?array
    {
        return $this->first(
            "SELECT
                dk.iddangky,
                dk.idgiaidau,
                dk.iddoibong,
                dk.idhuanluyenvien,
                dk.ngaydangky,
                dk.trangthai,
                dk.lydotuchoi,
                db.tendoibong,
                db.logo AS doibong_logo,
                db.diaphuong AS doibong_diaphuong,
                db.trangthai AS doibong_trangthai,
                hlv.bangcap AS huanluyenvien_bangcap,
                hlv.kinhnghiem AS huanluyenvien_kinhnghiem,
                hlv.trangthai AS huanluyenvien_trangthai,
                nd.idnguoidung AS huanluyenvien_idnguoidung,
                TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) AS huanluyenvien_hoten,
                tk.username AS huanluyenvien_username,
                tk.email AS huanluyenvien_email
             FROM Dangkygiaidau dk
             JOIN Doibong db ON db.iddoibong = dk.iddoibong
             JOIN Huanluyenvien hlv ON hlv.idhuanluyenvien = dk.idhuanluyenvien
             JOIN Nguoidung nd ON nd.idnguoidung = hlv.idnguoidung
             JOIN Taikhoan tk ON tk.idtaikhoan = nd.idtaikhoan
             WHERE dk.idgiaidau = :tournament_id
               AND dk.iddangky = :registration_id
             LIMIT 1",
            [
                'tournament_id' => $tournamentId,
                'registration_id' => $registrationId,
            ]
        );
    }

    public function approvedRegistrationCount(int $tournamentId): int
    {
        $row = $this->first(
            "SELECT COUNT(*) AS total
             FROM Dangkygiaidau
             WHERE idgiaidau = :tournament_id
               AND trangthai = 'DA_DUYET'",
            ['tournament_id' => $tournamentId]
        );

        return (int) ($row['total'] ?? 0);
    }

    public function decideRegistration(
        int $tournamentId,
        int $registrationId,
        string $oldStatus,
        string $newStatus,
        ?string $rejectionReason,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): void {
        $db = $this->db();
        $action = $newStatus === 'DA_DUYET' ? 'Duyet dang ky doi bong' : 'Tu choi dang ky doi bong';

        try {
            $db->beginTransaction();

            $statement = $db->prepare(
                "UPDATE Dangkygiaidau
                 SET trangthai = :new_status,
                     lydotuchoi = :rejection_reason
                 WHERE iddangky = :registration_id
                   AND idgiaidau = :tournament_id
                   AND trangthai = :old_status"
            );

            $statement->execute([
                'new_status' => $newStatus,
                'rejection_reason' => $rejectionReason,
                'registration_id' => $registrationId,
                'tournament_id' => $tournamentId,
                'old_status' => $oldStatus,
            ]);

            if ($statement->rowCount() !== 1) {
                throw new \RuntimeException('REGISTRATION_NOT_DECIDED');
            }

            $this->recordStatusHistory('DANG_KY_GIAI', $registrationId, $oldStatus, $newStatus, $action, $actorAccountId);
            $this->recordSystemLog($actorAccountId, $action, 'Dangkygiaidau', $registrationId, $ipAddress, $logNote);

            $db->commit();
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function findById(int $tournamentId): ?array
    {
        return $this->first(
            "SELECT
                gd.idgiaidau,
                gd.tengiaidau,
                gd.mota,
                gd.thoigianbatdau,
                gd.thoigianketthuc,
                gd.diadiem,
                gd.quymo,
                gd.hinhanh,
                gd.trangthai,
                gd.trangthaidangky,
                gd.idbantochuc,
                gd.ngaytao,
                gd.ngaycapnhat,
                btc.donvi AS bantochuc_donvi,
                btc.chucvu AS bantochuc_chucvu
             FROM Giaidau gd
             JOIN Bantochuc btc ON btc.idbantochuc = gd.idbantochuc
             WHERE gd.idgiaidau = :tournament_id
             LIMIT 1",
            ['tournament_id' => $tournamentId]
        );
    }

    public function rulesForTournament(int $tournamentId): array
    {
        $statement = $this->db()->prepare(
            "SELECT iddieule, idgiaidau, tieude, noidung, filedinhkem, ngaytao
             FROM Dieulegiaidau
             WHERE idgiaidau = :tournament_id
             ORDER BY iddieule"
        );

        $statement->execute(['tournament_id' => $tournamentId]);

        return $statement->fetchAll();
    }

    private function insertRules(int $tournamentId, array $rules): void
    {
        $statement = $this->db()->prepare(
            "INSERT INTO Dieulegiaidau (idgiaidau, tieude, noidung, filedinhkem)
             VALUES (:tournament_id, :title, :content, :attachment)"
        );

        foreach ($rules as $rule) {
            $statement->execute([
                'tournament_id' => $tournamentId,
                'title' => $rule['tieude'],
                'content' => $rule['noidung'],
                'attachment' => $rule['filedinhkem'],
            ]);
        }
    }

    private function updateTournamentFields(int $tournamentId, array $tournament): void
    {
        $sets = [];
        $bindings = ['tournament_id' => $tournamentId];
        $fields = ['tengiaidau', 'mota', 'thoigianbatdau', 'thoigianketthuc', 'diadiem', 'quymo', 'hinhanh'];

        foreach ($fields as $field) {
            if (!array_key_exists($field, $tournament)) {
                continue;
            }

            $sets[] = "{$field} = :{$field}";
            $bindings[$field] = $tournament[$field];
        }

        if ($sets === []) {
            return;
        }

        $sets[] = 'ngaycapnhat = CURRENT_TIMESTAMP';

        $statement = $this->db()->prepare(
            'UPDATE Giaidau SET ' . implode(', ', $sets) . " WHERE idgiaidau = :tournament_id AND trangthai = 'CHUA_CONG_BO'"
        );

        $statement->execute($bindings);

        if ($statement->rowCount() !== 1) {
            throw new \RuntimeException('TOURNAMENT_NOT_UPDATED');
        }
    }

    private function replaceRules(int $tournamentId, array $rules): void
    {
        $statement = $this->db()->prepare(
            "DELETE FROM Dieulegiaidau
             WHERE idgiaidau = :tournament_id"
        );
        $statement->execute(['tournament_id' => $tournamentId]);

        $this->insertRules($tournamentId, $rules);
    }

    private function recordSystemLog(?int $accountId, string $action, string $targetTable, ?int $targetId, ?string $ipAddress, ?string $note = null): void
    {
        $statement = $this->db()->prepare(
            "INSERT INTO Nhatkyhethong (idtaikhoan, hanhdong, bangtacdong, iddoituong, ipaddress, ghichu)
             VALUES (:account_id, :action, :target_table, :target_id, :ip_address, :note)"
        );

        $statement->execute([
            'account_id' => $accountId,
            'action' => $action,
            'target_table' => $targetTable,
            'target_id' => $targetId,
            'ip_address' => $ipAddress,
            'note' => $note,
        ]);
    }

    private function recordStatusHistory(string $targetType, int $targetId, ?string $oldStatus, string $newStatus, ?string $reason, ?int $actorId): void
    {
        $statement = $this->db()->prepare(
            "INSERT INTO Nhatkytrangthai (loaidoituong, iddoituong, trangthaicu, trangthaimoi, lydo, idnguoithuchien)
             VALUES (:target_type, :target_id, :old_status, :new_status, :reason, :actor_id)"
        );

        $statement->execute([
            'target_type' => $targetType,
            'target_id' => $targetId,
            'old_status' => $oldStatus,
            'new_status' => $newStatus,
            'reason' => $reason,
            'actor_id' => $actorId,
        ]);
    }
}
