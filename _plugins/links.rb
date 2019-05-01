
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

def render_javadoc(context, text, url_only)
  clz = text.strip
  short = true
  if not url_only
    args = text.strip.split(' ', 2)
    if args[0] == '-f'
      short = false
      clz = args[1]
    elsif args[0] == '-c'
      clz = args[1]
    end
  end
  base = context.registers[:site].config['javadoc_base']
  v = context.environments.first["page"]["javadoc_version"]
  if v.nil?
    v = context.registers[:site].config['javadoc_version']
  end
  clz_slash = convert_package(clz)
  clz_name = clz.split('.').last

  if not clz.start_with?('org.apache.accumulo.')
    raise "Unknown package prefix for #{clz}"
  end

  # Default is accumulo-<module> but handle corner cases below
  jmodule = 'accumulo-' + clz.split('.')[3]
  if clz.start_with?('org.apache.accumulo.server')
    jmodule = 'accumulo-server-base'
  elsif clz.start_with?('org.apache.accumulo.hadoop.mapred')
    jmodule = 'accumulo-hadoop-mapreduce'
  elsif clz.start_with?('org.apache.accumulo.iteratortest')
    jmodule = 'accumulo-iterator-test-harness'
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

class JavadocLinkTag < Liquid::Tag
  def initialize(tag_name, text, tokens)
    super
    @text = text
  end

  def render(context)
    return render_javadoc(context, @text, false)
  end
end

class JavadocUrlTag < Liquid::Tag
  def initialize(tag_name, text, tokens)
    super
    @text = text
  end

  def render(context)
    return render_javadoc(context, @text, true)
  end
end

def render_prop(context, text, link)
  args = text.split(' ')
  type = 'server'
  prop = args[0]
  if args[0] == '-c'
    type = 'client'
    prop = args[1]
  elsif args[0] == '-s'
    type = 'server'
    prop = args[1]
  end
  base = context.environments.first["page"]["docs_baseurl"]
  if base.nil?
    base = context.registers[:site].config['docs_baseurl']
  end
  prop_enc = prop.gsub('.\\*', '.*').gsub('.', '_').gsub('_*', '_prefix')
  url = "#{base}/configuration/server-properties##{prop_enc}"
  if type == 'client'
    url = "#{base}/configuration/client-properties##{prop_enc}"
  end
  if link
    return "[#{prop}](#{url})"
  end
  return url
end

class PropertyUrlTag < Liquid::Tag
  def initialize(tag_name, text, tokens)
    super
    @text = text
  end

  def render(context)
    return render_prop(context, @text, false)
  end
end

class PropertyLinkTag < Liquid::Tag
  def initialize(tag_name, text, tokens)
    super
    @text = text
  end

  def render(context)
    return render_prop(context, @text, true)
  end
end

def render_doc(context, text, link)
  base = context.environments.first["page"]["docs_baseurl"]
  if base.nil?
    base = context.registers[:site].config['docs_baseurl']
  end
  url = "#{base}/#{@text}"
  if not link
    return url
  end
  page = @text.split('/').last
  return "[#{page}](#{url})"
end

class DocLinkTag < Liquid::Tag
  def initialize(tag_name, text, tokens)
    super
    @text = text
  end

  def render(context)
    return render_doc(context, @text, true)
  end
end

class DocUrlTag < Liquid::Tag
  def initialize(tag_name, text, tokens)
    super
    @text = text
  end

  def render(context)
    return render_doc(context, @text, false)
  end
end

class GitHubIssueTag < Liquid::Tag
  def initialize(tag_name, text, tokens)
    super
    @text = text
  end

  def render(context)
    # TODO sanity check text
    # TODO support optional pound char like #123
    url = "https://github.com/apache/accumulo/issues/#{@text}"
    return "[##{@text}](#{url})"
  end
end

class JiraTag < Liquid::Tag
  def initialize(tag_name, text, tokens)
    super
    @text = text
  end

  def render(context)
    # TODO sanity check text
    # TODO accept number without ACCUMULO- prefix
    url = "https://issues.apache.org/jira/browse/#{@text}"
    return "[#{@text}](#{url})"
  end
end

class GitHubCodeTag < Liquid::Tag
  def initialize(tag_name, text, tokens)
    super
    @text = text
  end

  def render(context)
    args = @text.split(' ')
    path = args[0]
    branch = context.environments.first["page"]["gh_branch"]
    if branch.nil?
      branch = context.registers[:site].config["gh_branch"]
    end
    if args[0] == '-b'
      branch = args[1]
      path = args[2]
    end
    file_name = path.split('/').last
    url = "https://github.com/apache/accumulo/blob/#{branch}/#{path}"
    return "[#{file_name}](#{url})"
  end
end

Liquid::Template.register_tag('jlink', JavadocLinkTag)
Liquid::Template.register_tag('jurl', JavadocUrlTag)
Liquid::Template.register_tag('plink', PropertyLinkTag)
Liquid::Template.register_tag('purl', PropertyUrlTag)
Liquid::Template.register_tag('dlink', DocLinkTag)
Liquid::Template.register_tag('durl', DocUrlTag)
Liquid::Template.register_tag('ghi', GitHubIssueTag)
Liquid::Template.register_tag('ghc', GitHubCodeTag)
Liquid::Template.register_tag('jira', JiraTag)
