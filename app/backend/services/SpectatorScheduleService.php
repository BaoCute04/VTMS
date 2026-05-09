<?php

declare(strict_types=1);

namespace App\Backend\Services;

use App\Backend\Core\Http\Request;
use App\Backend\Models\Lichthidau;
use App\Backend\Models\Nguoidung;
use Throwable;

final class SpectatorScheduleService extends SpectatorServiceSupport
{
    private const MATCH_STATUSES = ['CHUA_DIEN_RA', 'SAP_DIEN_RA', 'DANG_DIEN_RA', 'TAM_DUNG', 'DA_KET_THUC', 'DA_HUY'];

    private Lichthidau $schedule;

    public function __construct(?Lichthidau $schedule = null, ?Nguoidung $users = null)
    {
        parent::__construct($users);
        $this->schedule = $schedule ?? new Lichthidau();
    }

    public function all(int $accountId, array $filters = [], ?Request $request = null): array
    {
        [$normalized, $errors] = $this->commonFilters($filters, self::MATCH_STATUSES);

        if ($errors !== []) {
            return $this->failure('Bo loc lich thi dau khong hop le.', 422, $errors);
        }

        try {
            $matches = $this->schedule->matchesForSpectator($normalized);
            $this->recordView(
                $accountId,
                'Khan gia xem lich thi dau',
                'Trandau',
                null,
                $request,
                sprintf('Khan gia #%d xem %d tran dau cong khai.', $accountId, count($matches))
            );

            return [
                'ok' => true,
                'status' => 200,
                'message' => 'Lay lich thi dau thanh cong.',
                'matches' => $matches,
                'meta' => [
                    'filters' => $normalized,
                    'match_statuses' => self::MATCH_STATUSES,
                ],
            ];
        } catch (Throwable) {
            return $this->failure('Khong the lay lich thi dau.', 500, [
                'database' => 'Loi doc co so du lieu hoac ghi nhat ky.',
            ]);
        }
    }

    public function show(int $matchId, int $accountId, ?Request $request = null): array
    {
        try {
            $match = $this->schedule->findMatchForSpectator($matchId);

            if ($match === null) {
                return $this->failure('Khong tim thay tran dau cong khai.', 404);
            }

            $this->recordView(
                $accountId,
                'Khan gia xem chi tiet lich thi dau',
                'Trandau',
                $matchId,
                $request,
                sprintf('Khan gia #%d xem tran dau #%d.', $accountId, $matchId)
            );

            return [
                'ok' => true,
                'status' => 200,
                'message' => 'Lay chi tiet lich thi dau thanh cong.',
                'match' => $match,
            ];
        } catch (Throwable) {
            return $this->failure('Khong the lay chi tiet lich thi dau.', 500, [
                'database' => 'Loi doc co so du lieu hoac ghi nhat ky.',
            ]);
        }
    }
}
