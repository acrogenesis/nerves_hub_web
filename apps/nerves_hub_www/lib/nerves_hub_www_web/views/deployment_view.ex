defmodule NervesHubWWWWeb.DeploymentView do
  use NervesHubWWWWeb, :view

  alias NervesHubWebCore.Repo
  alias NervesHubWebCore.Firmwares.Firmware
  alias NervesHubWebCore.Deployments.Deployment

  import NervesHubWWWWeb.LayoutView, only: [health_status_icon: 1, help_icon: 1]

  def firmware_dropdown_options(firmwares) do
    firmwares
    |> Enum.map(&[value: &1.id, key: firmware_display_name(&1)])
  end

  def firmware_summary(%Firmware{version: nil} = f) do
    [
      f.platform,
      f.architecture
    ]
    |> Enum.join(" - ")
  end

  def firmware_summary(%Firmware{} = f) do
    [
      "v:#{firmware_display_name(f)}",
      f.platform,
      f.architecture
    ]
    |> Enum.join(" - ")
  end

  def firmware_summary(%Deployment{firmware: %Firmware{} = f}) do
    firmware_summary(f)
  end

  def firmware_summary(%Deployment{firmware: %Ecto.Association.NotLoaded{}} = deployment) do
    Repo.preload(deployment, [:firmware])
    |> firmware_summary()
  end

  def firmware_display_name(%Firmware{} = f) do
    case f.version do
      nil -> "--"
      version -> "#{version}"
    end
  end

  def help_message_for(field) do
    case field do
      :failure_threshold ->
        "Maximum number of target devices from this deployment that can be in an unhealthy state before marking the deployment unhealthy"

      :failure_rate ->
        "Maximum number of device install failures from this deployment within X seconds before being marked unhealthy"

      :device_failure_rate ->
        "Maximum number of device failures within X seconds a device can have for this deployment before being marked unhealthy"

      :device_failure_threshold ->
        "Maximum number of install attempts and/or failures a device can have for this deployment before being marked unhealthy"
    end
  end

  def version(%Deployment{conditions: %{"version" => ""}}), do: "-"
  def version(%Deployment{conditions: %{"version" => version}}), do: version

  def active(%Deployment{is_active: true}), do: "Yes"
  def active(%Deployment{is_active: false}), do: "No"

  def opposite_status(%Deployment{is_active: true}), do: "Inactive"
  def opposite_status(%Deployment{is_active: false}), do: "Active"

  def tags(%Deployment{conditions: %{"tags" => tags}}), do: tags
end
