defmodule RewardsServiceWeb.UserController do
  use RewardsServiceWeb, :controller

  alias RewardsService.Accounts

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> json(%{
          data: %{
            id: user.id,
            email: user.email,
            name: user.name,
            api_key: user.api_key,
            inserted_at: user.inserted_at
          }
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def show(conn, %{"id" => id}) do
    case Accounts.get_user(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "user not found"})

      user ->
        conn
        |> put_status(:ok)
        |> json(%{
          data: %{
            id: user.id,
            email: user.email,
            name: user.name,
            inserted_at: user.inserted_at
          }
        })
    end
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
