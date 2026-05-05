<?php

declare(strict_types=1);

namespace App\Backend\Controllers;

use App\Backend\Core\Auth\Auth;
use App\Backend\Core\Controller;
use App\Backend\Core\Http\Request;
use App\Backend\Core\Http\Response;
use App\Backend\Services\OrganizerTournamentService;

final class OrganizerTournamentController extends Controller
{
    private OrganizerTournamentService $service;

    public function __construct()
    {
        $this->service = new OrganizerTournamentService();
    }

    public function page(Request $request): Response
    {
        return $this->view('bantochuc.tournaments', [
            'pageTitle' => 'VTMS - Quan ly giai dau',
            'styles' => ['css/organizer-tournaments.css'],
            'scripts' => ['js/organizer-tournaments.js'],
        ]);
    }

    public function index(Request $request): Response
    {
        return $this->respond(
            $this->service->all($this->accountId(), [
                'q' => $request->query('q', ''),
                'status' => $request->query('status', $request->query('trangthai', '')),
                'registration_status' => $request->query('registration_status', $request->query('reg_status', $request->query('trangthaidangky', ''))),
                'from' => $request->query('from', ''),
                'to' => $request->query('to', ''),
            ])
        );
    }

    public function store(Request $request): Response
    {
        return $this->respond(
            $this->service->create($request->all(), $this->accountId(), $request)
        );
    }

    public function show(Request $request): Response
    {
        $tournamentId = $this->routeTournamentId($request);

        if ($tournamentId === null) {
            return $this->notFound();
        }

        return $this->respond(
            $this->service->find($tournamentId, $this->accountId())
        );
    }

    public function update(Request $request): Response
    {
        $tournamentId = $this->routeTournamentId($request);

        if ($tournamentId === null) {
            return $this->notFound();
        }

        return $this->respond(
            $this->service->update($tournamentId, $request->all(), $this->accountId(), $request)
        );
    }

    public function destroy(Request $request): Response
    {
        $tournamentId = $this->routeTournamentId($request);

        if ($tournamentId === null) {
            return $this->notFound();
        }

        return $this->respond(
            $this->service->delete($tournamentId, $this->accountId(), $request)
        );
    }

    public function publish(Request $request): Response
    {
        $tournamentId = $this->routeTournamentId($request);

        if ($tournamentId === null) {
            return $this->notFound();
        }

        return $this->respond(
            $this->service->publish($tournamentId, $this->accountId(), $request)
        );
    }

    public function registrations(Request $request): Response
    {
        $tournamentId = $this->routeTournamentId($request);

        if ($tournamentId === null) {
            return $this->notFound();
        }

        return $this->respond(
            $this->service->registrations($tournamentId, $this->accountId(), [
                'status' => $request->query('status', $request->query('trangthai', '')),
                'q' => $request->query('q', $request->query('keyword', '')),
            ])
        );
    }

    public function openRegistrations(Request $request): Response
    {
        $tournamentId = $this->routeTournamentId($request);

        if ($tournamentId === null) {
            return $this->notFound();
        }

        return $this->respond(
            $this->service->openRegistrations($tournamentId, $this->accountId(), $request)
        );
    }

    public function closeRegistrations(Request $request): Response
    {
        $tournamentId = $this->routeTournamentId($request);

        if ($tournamentId === null) {
            return $this->notFound();
        }

        return $this->respond(
            $this->service->closeRegistrations($tournamentId, $this->accountId(), $request)
        );
    }

    public function approveRegistration(Request $request): Response
    {
        $tournamentId = $this->routeTournamentId($request);
        $registrationId = $this->routeRegistrationId($request);

        if ($tournamentId === null || $registrationId === null) {
            return $this->notFound();
        }

        return $this->respond(
            $this->service->approveRegistration($tournamentId, $registrationId, $this->accountId(), $request)
        );
    }

    public function rejectRegistration(Request $request): Response
    {
        $tournamentId = $this->routeTournamentId($request);
        $registrationId = $this->routeRegistrationId($request);

        if ($tournamentId === null || $registrationId === null) {
            return $this->notFound();
        }

        return $this->respond(
            $this->service->rejectRegistration($tournamentId, $registrationId, $request->all(), $this->accountId(), $request)
        );
    }

    private function accountId(): int
    {
        return (int) (Auth::user()['id'] ?? 0);
    }

    private function routeTournamentId(Request $request): ?int
    {
        $raw = (string) $request->route('id', '');

        if ($raw === '' || !ctype_digit($raw)) {
            return null;
        }

        $tournamentId = (int) $raw;

        return $tournamentId > 0 ? $tournamentId : null;
    }

    private function routeRegistrationId(Request $request): ?int
    {
        $raw = (string) $request->route('registrationId', '');

        if ($raw === '' || !ctype_digit($raw)) {
            return null;
        }

        $registrationId = (int) $raw;

        return $registrationId > 0 ? $registrationId : null;
    }

    private function respond(array $result): Response
    {
        $payload = [
            'success' => $result['ok'],
            'message' => $result['message'],
        ];

        if (array_key_exists('tournament', $result)) {
            $payload['data'] = $result['tournament'];
        }

        if (array_key_exists('tournaments', $result)) {
            $payload['data'] = $result['tournaments'];
        }

        if (array_key_exists('registrations', $result)) {
            $payload['data'] = $result['registrations'];
        }

        if (array_key_exists('registration', $result)) {
            $payload['data'] = $result['registration'];
        }

        if (array_key_exists('meta', $result)) {
            $payload['meta'] = $result['meta'];
        }

        if (array_key_exists('deleted_id', $result)) {
            $payload['deleted_id'] = $result['deleted_id'];
        }

        if (!empty($result['errors'])) {
            $payload['errors'] = $result['errors'];
        }

        return Response::json($payload, (int) $result['status']);
    }

    private function notFound(): Response
    {
        return Response::json([
            'success' => false,
            'message' => 'Khong tim thay giai dau.',
        ], 404);
    }
}
