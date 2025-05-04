module ApplicationHelper
  def notice_banner(name)
    if name == "notice"
      "bg-green-100 border-green-400 text-green-700"
    else
      "bg-red-100 border-red-400 text-red-700"
    end
  end

  def initials_or_emoji(user)
    user.emoji ? user.emoji : user.name[0].upcase + user.last_name[0].upcase
  end

  # Helper to create sortable links for table headers
  def sort_link_to(name, column, params, list_name)
    direction = if params[:sort] == column.to_s && params[:direction] == "asc"
                  "desc"
    else
                  "asc"
    end

    icon = if params[:sort] == column.to_s
             direction == "asc" ? "↑" : "↓"
    else
             ""
    end

    # Create a link that works with Turbo Frame
    link_to "#{name} #{icon}".html_safe,
            request.params.merge(sort: column, direction: direction),
            data: { turbo_frame: list_name },
            class: "text-gray-500 hover:text-gray-700"
  end

  # Helper for status badges
  def status_badge(status)
    case status
    when "Nuevo"
      "bg-blue-100 text-blue-800"
    when "WIP"
      "bg-yellow-100 text-yellow-800"
    when "Cerrado"
      "bg-green-100 text-green-800"
    when "Baja"
      "bg-red-100 text-red-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end
end
