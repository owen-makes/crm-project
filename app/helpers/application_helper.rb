module ApplicationHelper
  def notice_banner(name)
    if name == "notice"
      "bg-green-100 border-green-400 text-green-700"
    else
      "bg-red-100 border-red-400 text-red-700"
    end
  end
end
