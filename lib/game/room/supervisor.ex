defmodule Game.Room.Supervisor do
  @moduledoc """
  Supervisor for Rooms
  """

  use Supervisor

  alias Game.Room
  alias Game.Zone
  alias Game.Zone.Repo

  def start_link(zone) do
    Supervisor.start_link(__MODULE__, zone, id: zone.id)
  end

  @doc """
  Return all zones
  """
  @spec all() :: [map]
  def all() do
    Repo.all()
  end

  @doc """
  Return all rooms that are currently online
  """
  @spec rooms(pid :: pid) :: [pid]
  def rooms(pid) do
    pid
    |> Supervisor.which_children()
    |> Enum.map(&(elem(&1, 1)))
  end

  @doc """
  """
  @spec start_child(pid, room :: Room.t) :: :ok
  def start_child(pid, room) do
    child_spec = worker(Room, [room], id: room.id, restart: :permanent)
    Supervisor.start_child(pid, child_spec)
  end

  def init(zone) do
    children = zone.id
    |> Room.for_zone()
    |> Enum.map(fn (room) ->
      worker(Room, [room], id: room.id, restart: :permanent)
    end)

    Zone.room_supervisor(zone.id, self())

    supervise(children, strategy: :one_for_one)
  end
end