<?php

declare(strict_types=1);

namespace App\Backend\Models;

use App\Backend\Core\Model;
use Throwable;

final class Tucachthamgia extends Model
{
    private static bool $schemaReady = false;

    public function __construct()
    {
        $this->ensureSchema();
    }

    public function candidatesForOrganizer(int $organizerId, array $filters = []): array
    {
        $where = [
            'gsrc.idbantochuc = :organizer_id',
            "tt.trangthai = 'HOP_LE'",
            "tt.danhhieu = 'VO_DICH'",
            "gsrc.tinhchat IN ('CHINH_THUC', 'PHONG_TRAO')",
            "gdich.trangthai <> 'DA_HUY'",
        ];
        $bindings = ['organizer_id' => $organizerId];

        if (($filters['q'] ?? '') !== '') {
            $where[] = "(db.tendoibong LIKE :keyword OR gsrc.tengiaidau LIKE :keyword OR gdich.tengiaidau LIKE :keyword)";
            $bindings['keyword'] = '%' . $filters['q'] . '%';
        }

        if (($filters['source_tournament_id'] ?? '') !== '') {
            $where[] = 'tt.idgiaidau = :source_tournament_id';
            $bindings['source_tournament_id'] = (int) $filters['source_tournament_id'];
        }

        if (($filters['achievement'] ?? '') !== '') {
            $where[] = 'tt.danhhieu = :achievement';
            $bindings['achievement'] = (string) $filters['achievement'];
        }

        $statement = $this->db()->prepare(
            "SELECT
                tt.idthanhtich,
                tt.iddoibong,
                tt.idgiaidau AS idgiaidau_nguon,
                tt.idcapgiaidau AS idcapgiaidau_nguon,
                tt.hang_dat_duoc,
                tt.danhhieu,
                tt.ngay_cong_nhan,
                db.tendoibong,
                db.diaphuong,
                kvdoi.tenkhuvuc AS tenkhuvuc_doi,
                kvdoi.capkhuvuc AS capkhuvuc_doi,
                gsrc.tengiaidau AS tengiaidau_nguon,
                gsrc.idbantochuc AS idbantochuc_decu,
                cgsrc.macapgiaidau AS macapgiaidau_nguon,
                cgsrc.tencapgiaidau AS tencapgiaidau_nguon,
                kvsrc.tenkhuvuc AS tenkhuvuc_nguon,
                gdich.idgiaidau AS idgiaidau_dich,
                gdich.tengiaidau AS tengiaidau_dich,
                gdich.idbantochuc AS idbantochuc_nhan,
                cgdich.idcapgiaidau AS idcapgiaidau_dich,
                cgdich.macapgiaidau AS macapgiaidau_dich,
                cgdich.tencapgiaidau AS tencapgiaidau_dich,
                kvdich.tenkhuvuc AS tenkhuvuc_dich,
                btcnhan.donvi AS bantochuc_nhan,
                dc.iddecu,
                dc.trangthai AS trangthai_decu,
                dc.lydo_xet,
                dc.ghichu_decu,
                dc.lydo_xacnhan,
                dc.ngay_danhdau,
                dc.ngay_decu,
                dc.ngay_xacnhan
             FROM Thanhtichdoibong tt
             JOIN Doibong db ON db.iddoibong = tt.iddoibong
             JOIN Khuvuc kvdoi ON kvdoi.idkhuvuc = db.idkhuvucdaidien
             JOIN Giaidau gsrc ON gsrc.idgiaidau = tt.idgiaidau
             JOIN Capgiaidau cgsrc ON cgsrc.idcapgiaidau = tt.idcapgiaidau
             JOIN Khuvuc kvsrc ON kvsrc.idkhuvuc = gsrc.idkhuvucphamvi
             JOIN Capgiaidau cgdich ON cgdich.idcapgiaidau = cgsrc.idcapgiaidau - 1
             JOIN Giaidau gdich ON gdich.idcapgiaidau = cgdich.idcapgiaidau
                AND gdich.idkhuvucphamvi = kvsrc.idkhuvuccha
             JOIN Khuvuc kvdich ON kvdich.idkhuvuc = gdich.idkhuvucphamvi
             JOIN Bantochuc btcnhan ON btcnhan.idbantochuc = gdich.idbantochuc
             LEFT JOIN decutucachthamgia dc ON dc.idthanhtich = tt.idthanhtich
                AND dc.idgiaidau_dich = gdich.idgiaidau
             WHERE " . implode(' AND ', $where) . "
             ORDER BY tt.ngay_cong_nhan DESC, tt.idthanhtich DESC, gdich.thoigianbatdau ASC",
            $bindings
        );
        $statement->execute($bindings);

        return $statement->fetchAll();
    }

    public function incomingForOrganizer(int $organizerId, array $filters = []): array
    {
        $where = [
            'dc.idbantochuc_nhan = :organizer_id',
            "dc.trangthai IN ('DA_DE_CU', 'DA_XAC_NHAN', 'TU_CHOI')",
        ];
        $bindings = ['organizer_id' => $organizerId];

        if (($filters['q'] ?? '') !== '') {
            $where[] = "(db.tendoibong LIKE :keyword OR gsrc.tengiaidau LIKE :keyword OR gdich.tengiaidau LIKE :keyword OR btcdecu.donvi LIKE :keyword)";
            $bindings['keyword'] = '%' . $filters['q'] . '%';
        }

        $statement = $this->db()->prepare(
            "SELECT
                dc.*,
                db.tendoibong,
                db.diaphuong,
                kvdoi.tenkhuvuc AS tenkhuvuc_doi,
                kvdoi.capkhuvuc AS capkhuvuc_doi,
                gsrc.tengiaidau AS tengiaidau_nguon,
                gdich.tengiaidau AS tengiaidau_dich,
                cgsrc.macapgiaidau AS macapgiaidau_nguon,
                cgsrc.tencapgiaidau AS tencapgiaidau_nguon,
                cgdich.macapgiaidau AS macapgiaidau_dich,
                cgdich.tencapgiaidau AS tencapgiaidau_dich,
                btcdecu.donvi AS bantochuc_decu,
                tt.danhhieu,
                tt.hang_dat_duoc,
                tt.ngay_cong_nhan
             FROM decutucachthamgia dc
             JOIN Doibong db ON db.iddoibong = dc.iddoibong
             JOIN Khuvuc kvdoi ON kvdoi.idkhuvuc = db.idkhuvucdaidien
             JOIN Giaidau gsrc ON gsrc.idgiaidau = dc.idgiaidau_nguon
             JOIN Giaidau gdich ON gdich.idgiaidau = dc.idgiaidau_dich
             JOIN Capgiaidau cgsrc ON cgsrc.idcapgiaidau = dc.idcapgiaidau_nguon
             JOIN Capgiaidau cgdich ON cgdich.idcapgiaidau = dc.idcapgiaidau_dich
             JOIN Bantochuc btcdecu ON btcdecu.idbantochuc = dc.idbantochuc_decu
             JOIN Thanhtichdoibong tt ON tt.idthanhtich = dc.idthanhtich
             WHERE " . implode(' AND ', $where) . "
             ORDER BY FIELD(dc.trangthai, 'DA_DE_CU', 'DU_DIEU_KIEN', 'DA_XAC_NHAN', 'TU_CHOI'), dc.ngay_decu DESC, dc.iddecu DESC",
            $bindings
        );
        $statement->execute($bindings);

        return $statement->fetchAll();
    }

    public function candidate(int $achievementId, int $targetTournamentId, int $organizerId): ?array
    {
        $rows = $this->candidatesForOrganizer($organizerId);

        foreach ($rows as $row) {
            if ((int) $row['idthanhtich'] === $achievementId && (int) $row['idgiaidau_dich'] === $targetTournamentId) {
                return $row;
            }
        }

        return null;
    }

    public function markEligible(array $candidate, int $accountId, ?string $note): int
    {
        $statement = $this->db()->prepare(
            "INSERT INTO decutucachthamgia
                (iddoibong, idthanhtich, idgiaidau_nguon, idgiaidau_dich, idcapgiaidau_nguon, idcapgiaidau_dich,
                 idbantochuc_decu, idbantochuc_nhan, trangthai, lydo_xet, idnguoi_danhdau, ngay_danhdau)
             VALUES
                (:team_id, :achievement_id, :source_tournament_id, :target_tournament_id, :source_level_id, :target_level_id,
                 :source_organizer_id, :target_organizer_id, 'DU_DIEU_KIEN', :note, :actor_id, CURRENT_TIMESTAMP)
             ON DUPLICATE KEY UPDATE
                trangthai = IF(trangthai IN ('DA_XAC_NHAN', 'DA_DE_CU'), trangthai, 'DU_DIEU_KIEN'),
                lydo_xet = VALUES(lydo_xet),
                idnguoi_danhdau = VALUES(idnguoi_danhdau),
                ngay_danhdau = VALUES(ngay_danhdau),
                ngaycapnhat = CURRENT_TIMESTAMP"
        );
        $statement->execute([
            'team_id' => (int) $candidate['iddoibong'],
            'achievement_id' => (int) $candidate['idthanhtich'],
            'source_tournament_id' => (int) $candidate['idgiaidau_nguon'],
            'target_tournament_id' => (int) $candidate['idgiaidau_dich'],
            'source_level_id' => (int) $candidate['idcapgiaidau_nguon'],
            'target_level_id' => (int) $candidate['idcapgiaidau_dich'],
            'source_organizer_id' => (int) $candidate['idbantochuc_decu'] ?: $this->sourceOrganizerId((int) $candidate['idgiaidau_nguon']),
            'target_organizer_id' => (int) $candidate['idbantochuc_nhan'],
            'note' => $note,
            'actor_id' => $accountId,
        ]);

        return (int) ($candidate['iddecu'] ?? 0) ?: $this->proposalId((int) $candidate['idthanhtich'], (int) $candidate['idgiaidau_dich']);
    }

    public function nominate(int $proposalId, int $organizerId, int $accountId, ?string $note): bool
    {
        $statement = $this->db()->prepare(
            "UPDATE decutucachthamgia
             SET trangthai = 'DA_DE_CU',
                 ghichu_decu = :note,
                 idnguoi_decu = :actor_id,
                 ngay_decu = CURRENT_TIMESTAMP,
                 ngaycapnhat = CURRENT_TIMESTAMP
             WHERE iddecu = :proposal_id
               AND idbantochuc_decu = :organizer_id
               AND trangthai = 'DU_DIEU_KIEN'
               AND idcapgiaidau_dich = idcapgiaidau_nguon - 1"
        );
        $statement->execute([
            'proposal_id' => $proposalId,
            'organizer_id' => $organizerId,
            'actor_id' => $accountId,
            'note' => $note,
        ]);

        return $statement->rowCount() === 1;
    }

    public function decide(int $proposalId, int $organizerId, int $accountId, bool $approved, ?string $note): bool
    {
        $newStatus = $approved ? 'DA_XAC_NHAN' : 'TU_CHOI';
        $db = $this->db();

        try {
            $db->beginTransaction();

            $statement = $db->prepare(
                "UPDATE decutucachthamgia
                 SET trangthai = :new_status,
                     lydo_xacnhan = :note,
                     idnguoi_xacnhan = :actor_id,
                     ngay_xacnhan = CURRENT_TIMESTAMP,
                     ngaycapnhat = CURRENT_TIMESTAMP
                 WHERE iddecu = :proposal_id
                   AND idbantochuc_nhan = :organizer_id
                   AND trangthai = 'DA_DE_CU'
                   AND idcapgiaidau_dich = idcapgiaidau_nguon - 1"
            );
            $statement->execute([
                'new_status' => $newStatus,
                'note' => $note,
                'actor_id' => $accountId,
                'proposal_id' => $proposalId,
                'organizer_id' => $organizerId,
            ]);

            if ($statement->rowCount() !== 1) {
                $db->rollBack();
                return false;
            }

            if ($approved) {
                $proposal = $this->proposal($proposalId);
                if ($proposal !== null) {
                    $this->grantHigherTournamentLevel($proposal);

                    if ($this->canCreateExplicitEligibility($proposal)) {
                        $this->grantExplicitEligibility($proposal, $accountId, $note);
                    }
                }
            }

            $db->commit();
            return true;
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function proposal(int $proposalId): ?array
    {
        return $this->first(
            "SELECT dc.*, gdich.idgiaidau, cgdich.capdoituongthamgia, kvdoi.capkhuvuc AS capkhuvuc_doi
             FROM decutucachthamgia dc
             JOIN Giaidau gdich ON gdich.idgiaidau = dc.idgiaidau_dich
             JOIN Capgiaidau cgdich ON cgdich.idcapgiaidau = gdich.idcapgiaidau
             JOIN Doibong db ON db.iddoibong = dc.iddoibong
             JOIN Khuvuc kvdoi ON kvdoi.idkhuvuc = db.idkhuvucdaidien
             WHERE dc.iddecu = :proposal_id
             LIMIT 1",
            ['proposal_id' => $proposalId]
        );
    }

    public function acceptedTeamIdsForTournament(int $tournamentId): array
    {
        if (!$this->tableExists()) {
            return [];
        }

        $statement = $this->db()->prepare(
            "SELECT DISTINCT iddoibong
             FROM decutucachthamgia
             WHERE idgiaidau_dich = :tournament_id
               AND trangthai = 'DA_XAC_NHAN'"
        );
        $statement->execute(['tournament_id' => $tournamentId]);

        return array_map('intval', array_column($statement->fetchAll(), 'iddoibong'));
    }

    private function canCreateExplicitEligibility(array $proposal): bool
    {
        return (string) ($proposal['capkhuvuc_doi'] ?? '') === (string) ($proposal['capdoituongthamgia'] ?? '');
    }

    private function grantHigherTournamentLevel(array $proposal): void
    {
        $statement = $this->db()->prepare(
            "UPDATE Doibong
             SET idcapgiaidau_duoc_tham_gia = CASE
                    WHEN idcapgiaidau_duoc_tham_gia IS NULL
                      OR :compared_target_level_id < idcapgiaidau_duoc_tham_gia
                        THEN :assigned_target_level_id
                    ELSE idcapgiaidau_duoc_tham_gia
                 END,
                 ngaycapnhat = CURRENT_TIMESTAMP
             WHERE iddoibong = :team_id"
        );
        $statement->execute([
            'compared_target_level_id' => (int) $proposal['idcapgiaidau_dich'],
            'assigned_target_level_id' => (int) $proposal['idcapgiaidau_dich'],
            'team_id' => (int) $proposal['iddoibong'],
        ]);
    }

    private function grantExplicitEligibility(array $proposal, int $accountId, ?string $note): void
    {
        $statement = $this->db()->prepare(
            "INSERT INTO Doidudieukienthamgia
                (idgiaidau, iddoibong, idthanhtich, nguon_dieukien, lydo_dieukien, trangthai, idnguoixacnhan, ghichu)
             VALUES
                (:tournament_id, :team_id, :achievement_id, 'BTC_CHON', :reason, 'DU_DIEU_KIEN', :actor_id, :note)
             ON DUPLICATE KEY UPDATE
                idthanhtich = VALUES(idthanhtich),
                nguon_dieukien = VALUES(nguon_dieukien),
                lydo_dieukien = VALUES(lydo_dieukien),
                trangthai = IF(trangthai IN ('DA_DANG_KY', 'DA_DUYET'), trangthai, 'DU_DIEU_KIEN'),
                idnguoixacnhan = VALUES(idnguoixacnhan),
                ghichu = VALUES(ghichu),
                ngay_xac_nhan = CURRENT_TIMESTAMP"
        );
        $statement->execute([
            'tournament_id' => (int) $proposal['idgiaidau_dich'],
            'team_id' => (int) $proposal['iddoibong'],
            'achievement_id' => (int) $proposal['idthanhtich'],
            'reason' => $note ?: 'BTC cap cao hon xac nhan de cu tu cach tham gia.',
            'actor_id' => $accountId,
            'note' => 'Tu de cu tu cach #' . (int) $proposal['iddecu'],
        ]);
    }

    private function proposalId(int $achievementId, int $targetTournamentId): int
    {
        $row = $this->first(
            "SELECT iddecu
             FROM decutucachthamgia
             WHERE idthanhtich = :achievement_id
               AND idgiaidau_dich = :target_tournament_id
             LIMIT 1",
            [
                'achievement_id' => $achievementId,
                'target_tournament_id' => $targetTournamentId,
            ]
        );

        return (int) ($row['iddecu'] ?? 0);
    }

    private function sourceOrganizerId(int $sourceTournamentId): int
    {
        $row = $this->first(
            "SELECT idbantochuc FROM Giaidau WHERE idgiaidau = :tournament_id LIMIT 1",
            ['tournament_id' => $sourceTournamentId]
        );

        return (int) ($row['idbantochuc'] ?? 0);
    }

    private function ensureSchema(): void
    {
        if (self::$schemaReady) {
            return;
        }

        $this->db()->exec(
            "CREATE TABLE IF NOT EXISTS decutucachthamgia (
                iddecu INT AUTO_INCREMENT PRIMARY KEY,
                iddoibong INT NOT NULL,
                idthanhtich INT NOT NULL,
                idgiaidau_nguon INT NOT NULL,
                idgiaidau_dich INT NOT NULL,
                idcapgiaidau_nguon INT NOT NULL,
                idcapgiaidau_dich INT NOT NULL,
                idbantochuc_decu INT NOT NULL,
                idbantochuc_nhan INT NOT NULL,
                trangthai VARCHAR(50) NOT NULL DEFAULT 'DU_DIEU_KIEN',
                lydo_xet VARCHAR(1000) NULL,
                ghichu_decu VARCHAR(1000) NULL,
                lydo_xacnhan VARCHAR(1000) NULL,
                idnguoi_danhdau INT NULL,
                idnguoi_decu INT NULL,
                idnguoi_xacnhan INT NULL,
                ngay_danhdau DATETIME NULL,
                ngay_decu DATETIME NULL,
                ngay_xacnhan DATETIME NULL,
                ngaytao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                ngaycapnhat DATETIME NULL,
                UNIQUE KEY uq_decu_thanhtich_giai (idthanhtich, idgiaidau_dich),
                KEY idx_decu_doi (iddoibong),
                KEY idx_decu_nguon (idgiaidau_nguon),
                KEY idx_decu_dich (idgiaidau_dich),
                KEY idx_decu_btc_decu (idbantochuc_decu),
                KEY idx_decu_btc_nhan (idbantochuc_nhan),
                KEY idx_decu_trangthai (trangthai)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci"
        );

        self::$schemaReady = true;
    }

    private function tableExists(): bool
    {
        $statement = $this->db()->query("SHOW TABLES LIKE 'decutucachthamgia'");

        return $statement !== false && $statement->fetch() !== false;
    }
}
