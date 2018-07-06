
def convert_package(package)
  retval = ''
  vals = package.split('.')
  vals.each_with_index do |value, index|
    retval << value
    if index != vals.size - 1
      if value =~ /^[a-z]/
        retval << '/'
      else
        retval << '.'
      end
    end
  end
  return retval
end

def render_link(context, text, short, url_only)
  clz = text.strip
  base = context.registers[:site].config['javadoc_base']
  v = context.environments.first["page"]["javadoc_version"]
  if v.nil?
    v = context.registers[:site].config['javadoc_version']
  end
  clz_slash = convert_package(clz)
  clz_name = clz.split('.').last

  jmodule = 'unknown'
  if clz.start_with?('org.apache.accumulo.core')
    jmodule = 'accumulo-core'
  elsif clz.start_with?('org.apache.accumulo.iteratortest')
    jmodule = 'accumulo-iterator-test-harness'
  elsif clz.start_with?('org.apache.accumulo.minicluster')
    jmodule = 'accumulo-minicluster'
  else
    raise "Unknown package prefix for #{clz}"
  end

  if clz_slash.include? "#"
    clz_only = convert_package(clz.split('#').first)
    method = clz.split('#').last
    url = "#{base}/#{jmodule}/#{v}/#{clz_only}.html##{method}"
  elsif clz_name =~ /^[a-z]/
    url = "#{base}/#{jmodule}/#{v}/#{clz_slash}/package-summary.html"
  else
    url = "#{base}/#{jmodule}/#{v}/#{clz_slash}.html"
  end
  if url_only
    return url
  end
  if short
    link_text = clz.split('.').last
  else
    link_text = clz
  end
  r = "[#{link_text}](#{url})"
  return r
end

class JavadocFullTag < Liquid::Tag
  def initialize(tag_name, text, tokens)
    super
    @text = text
  end

  def render(context)
    return render_link(context, @text, false, false)
  end
end

class JavadocClassTag < Liquid::Tag
  def initialize(tag_name, text, tokens)
    super
    @text = text
  end

  def render(context)
    return render_link(context, @text, true, false)
  end
end

class JavadocUrlTag < Liquid::Tag
  def initialize(tag_name, text, tokens)
    super
    @text = text
  end

  def render(context)
    return render_link(context, @text, false, true)
  end
end

class ServerPropertyTag < Liquid::Tag
  def initialize(tag_name, text, tokens)
    super
    @text = text
  end

  def render(context)
    base = context.environments.first["page"]["docs_baseurl"]
    if base.nil?
      base = context.registers[:site].config['docs_baseurl']
    end
    prop = @text.gsub('.', '_')
    return "#{base}/administration/properties##{prop}"
  end
end

class ClientPropertyTag < Liquid::Tag
  def initialize(tag_name, text, tokens)
    super
    @text = text
  end

  def render(context)
    base = context.environments.first["page"]["docs_baseurl"]
    if base.nil?
      base = context.registers[:site].config['docs_baseurl']
    end
    prop = @text.gsub('.', '_')
    return "#{base}/development/client-properties##{prop}"
  end
end

class DocTag < Liquid::Tag
  def initialize(tag_name, text, tokens)
    super
    @text = text
  end

  def render(context)
    base = context.environments.first["page"]["docs_baseurl"]
    if base.nil?
      base = context.registers[:site].config['docs_baseurl']
    end
    return "#{base}/#{@text}"
  end
end

Liquid::Template.register_tag('jfull', JavadocFullTag)
Liquid::Template.register_tag('jclass', JavadocClassTag)
Liquid::Template.register_tag('jurl', JavadocUrlTag)
Liquid::Template.register_tag('sprop', ServerPropertyTag)
Liquid::Template.register_tag('cprop', ClientPropertyTag)
Liquid::Template.register_tag('doc', DocTag)
