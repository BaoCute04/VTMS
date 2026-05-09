<?php

declare(strict_types=1);

namespace App\Backend\Services;

use App\Backend\Core\Http\Request;
use App\Backend\Models\Doibong;
use App\Backend\Models\Nguoidung;
use Throwable;

final class SpectatorClubInfoService extends SpectatorServiceSupport
{
    private Doibong $teams;

    public function __construct(?Doibong $teams = null, ?Nguoidung $users = null)
    {
        parent::__construct($users);
        $this->teams = $teams ?? new Doibong();
    }

    public function show(int $teamId, int $accountId, ?Request $request = null): array
    {
        try {
            $club = $this->teams->findClubForSpectator($teamId);

            if ($club === null) {
                return $this->failure('Khong tim thay cau lac bo cong khai.', 404);
            }

            $members = $this->teams->clubMembersForSpectator($teamId);
            $tournaments = $this->teams->clubTournamentsForSpectator($teamId);

            $this->recordView(
                $accountId,
                'Khan gia xem thong tin cau lac bo',
                'Doibong',
                $teamId,
                $request,
                sprintf('Khan gia #%d xem cau lac bo/doi bong #%d.', $accountId, $teamId)
            );

            return [
                'ok' => true,
                'status' => 200,
                'message' => 'Lay thong tin cau lac bo thanh cong.',
                'club' => $club,
                'members' => $members,
                'tournaments' => $tournaments,
            ];
        } catch (Throwable) {
            return $this->failure('Khong the lay thong tin cau lac bo.', 500, [
                'database' => 'Loi doc co so du lieu hoac ghi nhat ky.',
            ]);
        }
    }
}
