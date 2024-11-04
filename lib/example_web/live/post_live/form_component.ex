defmodule ExampleWeb.PostLive.FormComponent do
  use ExampleWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage post records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="post-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <%= for category <- ["foo", "bar"] do %>
          <.input
            type="checkbox"
            label={"#{category}"}
            name={@form.name <> "[categories][#{category}]"}
            id={@form.id <> "_categories_#{category}"}
            value={starts_with_category?(@form.source.source, category)}
          />
        <% end %>

        <:actions>
          <.button phx-disable-with="Saving...">Save Post</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  defp starts_with_category?(changeset, category) do
    category in List.wrap(changeset.data.categories)
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    IO.inspect(post_params)
    # {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, post_params))}
    {:noreply, socket}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: post_params) do
      {:ok, post} ->
        IO.inspect(post)
        notify_parent({:saved, post})

        socket =
          socket
          |> put_flash(:info, "Post #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{post: post}} = socket) do
    form =
      if post do
        AshPhoenix.Form.for_update(post, :update,
          as: "post",
          actor: socket.assigns.current_user,
          prepare_params: &prepare_params/2
        )
      else
        AshPhoenix.Form.for_create(Example.Blog.Post, :create,
          as: "post",
          actor: socket.assigns.current_user,
          prepare_params: &prepare_params/2
        )
      end

    assign(socket, form: to_form(form))
  end

  defp prepare_params(%{"categories" => categories} = params, _) do
    Map.put(
      params,
      "categories",
      categories |> Enum.filter(&(elem(&1, 1) == "true")) |> Enum.map(&elem(&1, 0))
    )
  end

  defp prepare_params(params, _), do: params
end
