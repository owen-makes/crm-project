module LeadsHelper
  def status_badge(status)
    status = status.to_s.downcase

    case status
    when "nuevo" then "bg-green-100 text-green-800"
    when "wip" then "bg-yellow-100 text-yellow-800"
    when "cerrado" then "bg-green-100 text-green-800"
    when "baja" then "bg-red-100 text-red-800"
    when "convertido" then "bg-blue-100 text-blue-800"
    else "bg-gray-100 text-gray-800"
    end
  end
end
