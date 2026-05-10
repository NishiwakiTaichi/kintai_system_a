class Bootstrap5LinkRenderer < WillPaginate::ActionView::LinkRenderer
  def html_container(html)
    tag(:nav, tag(:ul, html, class: 'pagination'))
  end

  def page_number(page)
    tag(:li, link(page, page), class: page == current_page ? 'page-item active' : 'page-item')
  end

  def previous_or_next_page(page, text, classname)
    tag(:li, link(text, page || '#'), class: page ? 'page-item' : 'page-item disabled')
  end

  def gap
    tag(:li, tag(:span, '...', class: 'page-link'), class: 'page-item disabled')
  end

  def link(text, target, attributes = {})
    super(text, target, attributes.merge(class: 'page-link'))
  end
end
