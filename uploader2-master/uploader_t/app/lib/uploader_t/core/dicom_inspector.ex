defmodule UploaderT.Core.DicomInspector do

  @doc """
    Inspects a DICOM file
  """
  def inspect(:ae_title, path) do
    # Splits the absolute file path on "/"
    # Make a list with the last string on the previous list as its only element
    # Find such only element and assign it to the pattern "filename"
    # Therefore, obtains the filename
    file_name = String.split(path, "/") |> Enum.take(-1) |> Enum.at(0)

    {ae_title, status_code} = System.cmd("python3", ["lib/uploader_t/core/py/get_ae_title.py", "observable/" <> file_name])
    if status_code == 0 do
      {:ok, ae_title}
    else
      {:error, status_code}
    end
  end

  def inspect(:study_instance_uid, path) do
    # Splits the absolute file path on "/"
    # Make a list with the last string on the previous list as its only element
    # Find such only element and assign it to the pattern "filename"
    # Therefore, obtains the filename
    file_name = String.split(path, "/") |> Enum.take(-1) |> Enum.at(0)

    {study_instance_uid, status_code} = System.cmd("python3", ["lib/uploader_t/core/py/get_study_instance_uid.py", "observable/" <> file_name])
    if status_code == 0 do
      {:ok, study_instance_uid}
    else
      {:error, status_code}
    end
  end

  def inspect(:study_description, path) do
    # Splits the absolute file path on "/"
    # Make a list with the last string on the previous list as its only element
    # Find such only element and assign it to the pattern "filename"
    # Therefore, obtains the filename
    file_name = String.split(path, "/") |> Enum.take(-1) |> Enum.at(0)

    {study_description, status_code} = System.cmd("python3", ["lib/uploader_t/core/py/get_study_description.py", "observable/" <> file_name])
    if status_code == 0 do
      {:ok, study_description}
    else
      {:error, status_code}
    end
  end

end
