defmodule RewardsService.Accounts do
  @moduledoc """
  The Accounts context - manages users and API key authentication.
  """
  alias RewardsService.Repo
  alias RewardsService.Accounts.User

  @doc "Create a new user with email and name. Returns the user with a generated API key."
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Get a user by ID."
  def get_user(id) do
    Repo.get(User, id)
  end

  @doc "Authenticate a user by their raw API key."
  def get_user_by_api_key(key) do
    hash = :crypto.hash(:sha256, key) |> Base.encode16(case: :lower)

    case Repo.get_by(User, api_key_hash: hash) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
end
