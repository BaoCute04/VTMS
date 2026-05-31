<?php

declare(strict_types=1);

namespace App\Backend\Services\Spectator;

use App\Backend\Core\Http\Request;
use App\Backend\Models\Bangxephang;
use App\Backend\Models\Nguoidung;
use Throwable;

final class SpectatorStandingService extends SpectatorServiceSupport
{
    private Bangxephang $standings;

    public function __construct(?Bangxephang $standings = null, ?Nguoidung $users = null)
    {
        parent::__construct($users);
        $this->standings = $standings ?? new Bangxephang();
    }

    public function all(int $accountId, array $filters = [], ?Request $request = null): array
    {
        [$normalized, $errors] = $this->commonFilters($filters);

        if ($errors !== []) {
            return $this->failure('Bo loc bang xep hang khong hop le.', 422, $errors);
        }

        try {
            $standings = $this->standings->listForSpectator($normalized);
            $this->recordView(
                $accountId,
                'Khan gia xem bang xep hang',
                'Bangxephang',
                null,
                $request,
                sprintf('Khan gia #%d xem %d bang xep hang da cong bo.', $accountId, count($standings))
            );

            return [
                'ok' => true,
                'status' => 200,
                'message' => 'Lay bang xep hang thanh cong.',
                'standings' => $standings,
                'meta' => [
                    'filters' => $normalized,
                    'publish_status' => 'DA_CONG_BO',
                ],
            ];
        } catch (Throwable) {
            return $this->failure('Khong the lay bang xep hang.', 500, [
                'database' => 'Loi doc co so du lieu hoac ghi nhat ky.',
            ]);
        }
    }

    public function show(int $rankingId, int $accountId, ?Request $request = null): array
    {
        try {
            $standing = $this->standings->findForSpectator($rankingId);

            if ($standing === null) {
                return $this->failure('Khong tim thay bang xep hang da cong bo.', 404);
            }

            $rows = $this->standings->detailsForRanking($rankingId);
            $this->recordView(
                $accountId,
                'Khan gia xem chi tiet bang xep hang',
                'Bangxephang',
                $rankingId,
                $request,
                sprintf('Khan gia #%d xem bang xep hang #%d.', $accountId, $rankingId)
            );

            return [
                'ok' => true,
                'status' => 200,
                'message' => 'Lay chi tiet bang xep hang thanh cong.',
                'standing' => $standing,
                'rows' => $rows,
            ];
        } catch (Throwable) {
            return $this->failure('Khong the lay chi tiet bang xep hang.', 500, [
                'database' => 'Loi doc co so du lieu hoac ghi nhat ky.',
            ]);
        }
    }

    public function latestByTournament(int $tournamentId, int $accountId, ?Request $request = null): array
    {
        try {
            $standing = $this->standings->latestPublishedForTournament($tournamentId);

            if ($standing === null) {
                return $this->failure('Khong tim thay bang xep hang da cong bo cua giai dau.', 404);
            }

            $rankingId = (int) $standing['idbangxephang'];
            $rows = $this->standings->detailsForRanking($rankingId);
            $this->recordView(
                $accountId,
                'Khan gia xem bang xep hang moi nhat cua giai dau',
                'Bangxephang',
                $rankingId,
                $request,
                sprintf('Khan gia #%d xem BXH moi nhat cua giai #%d.', $accountId, $tournamentId)
            );

            return [
                'ok' => true,
                'status' => 200,
                'message' => 'Lay bang xep hang moi nhat thanh cong.',
                'standing' => $standing,
                'rows' => $rows,
            ];
        } catch (Throwable) {
            return $this->failure('Khong the lay bang xep hang moi nhat.', 500, [
                'database' => 'Loi doc co so du lieu hoac ghi nhat ky.',
            ]);
        }
    }
}

