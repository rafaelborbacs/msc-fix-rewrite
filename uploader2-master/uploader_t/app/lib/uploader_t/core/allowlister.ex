defmodule UploaderT.Core.AllowLister do
  alias UploaderT.CRUD

  alias UploaderT.CRUD.Modality

  def allowed?(:ae_title, ae_title) do
    answer = CRUD.get_modality!(ae_title, :ae_title)

    case answer do
      %Modality{} ->
        true

      nil ->
        false

    end
  end
end
