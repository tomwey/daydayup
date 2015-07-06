module ApplicationHelper
  
  def notice_message
      flash_messages = []
      flash.each do |type, message|
        type = :success if type.to_s == "notice"
        type = :warning if type.to_s == "alert"
        type = :danger if type.to_s == "error"
        text = content_tag(:div, link_to("×", "#", class: "close", 'data-dismiss' => "alert") + message, class: "alert alert-#{type}", style: "margin-top: 20px;")
        flash_messages << text if message
      end
      flash_messages.join("\n").html_safe
    end
  
  def state_link_to(opts = {})
    state = opts[:state]

    message = if state 
      opts[:yes_text]
    else
      opts[:no_text]
    end
    
    html = <<-HTML
    <a href="#" data-remote="true" 
                data-yes-uri="#{opts[:yes_uri]}" 
                data-yes-text="#{opts[:yes_text]}" 
                data-no-uri="#{opts[:no_uri]}" 
                data-no-text="#{opts[:no_text]}"
                data-state="#{state}"
                onclick="App.updateState(this);" 
                class="btn btn-danger btn-xs" >
                #{message}
    </a>
    HTML
    
    html.html_safe
  end
end
