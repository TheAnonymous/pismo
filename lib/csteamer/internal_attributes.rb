module CSteamer
  # Internal attributes are different pieces of data we can extract from a document's content
  module InternalAttributes
    # Returns the title of the page/content - attempts to strip site name, etc, if possible
    def title
      title = @doc.match( '.entry h2',                                                      # Common style
                          '.entryheader h1',                                                # Ruby Inside/Kubrick
                          '.entry-title a',                                               # Common Blogger/Blogspot rules
                          '.post-title a',
                          '.posttitle a',
                          '.entry-title',
                          '.post-title',
                          '.posttitle',
                          '#pname a',                                                       # Google Code style
                          'h1.headermain',
                          'h1.title',
                          '.mxb h1'                                                         # BBC News
                        )
      
      # If all else fails, go to the HTML title
      unless title
        title = @doc.match('title')
        return unless title

        # Strip off any leading or trailing site names - a scrappy way to try it out..
        title = title.split(/\s+(\-|\||\:)\s+/).sort_by { |i| i.length }.last.strip
      end
      
      title
    end
    
    # Returns the author of the page/content
    def author
      author = @doc.match('.post-author .fn',
                          '.wire_author',      
                          ['meta[@name="author"]', lambda { |el| el.attr('content') }],     # Traditional meta tag style
                          '.byline a',                                                      # Ruby Inside style
                          '.post_subheader_left a',                                         # TechCrunch style
                          '.byl',                                                           # BBC News style
                          '.meta a',
                          '.articledata .author a',
                          '#owners a',                                                      # Google Code style
                          '.author a',
                          '.author'
                          )
                          
      return unless author
    
      # Strip off any "By [whoever]" section
      author.sub!(/^by\s+/i, '')
      
      author
    end
    
    # Returns the "description" of the page, usually comes from a meta tag
    def description
      @doc.match(
                  ['meta[@name="description"]', lambda { |el| el.attr('content') }],
                  ['meta[@name="Description"]', lambda { |el| el.attr('content') }],
                  '.description'
       )
    end
    
    # Returns the "lede" or first paragraph of the story/page
    def lede
      lede = @doc.match( 
                  '.subhead',
                  '//div[@class="entrytext"]//p[string-length()>10]',                      # Ruby Inside / Kubrick style
                  'section p',
                  '.entry .text p',
                  '.entry-content p',
                  '#wikicontent p',                                                        # Google Code style
                  '//td[@class="storybody"]/p[string-length()>10]',                        # BBC News style
                  # The below is a horrible, horrible way to pluck out lead paras from crappy Blogspot blogs that
                  # don't use <p> tags..
                  ['.entry-content', lambda { |el| el.inner_html[/(#{el.inner_text[0..4].strip}.*?)\<br/, 1] }],
                  ['.entry', lambda { |el| el.inner_html[/(#{el.inner_text[0..4].strip}.*?)\<br/, 1] }],
                  '.entry',
                  '#content p'
                  )
                        
      lede
    end
    
    # Returns URL to the site's favicon
    def favicon
      url = @doc.match( ['link[@rel="fluid-icon"]', lambda { |el| el.attr('href') }],      # Get a Fluid icon if possible..
                        ['link[@rel="shortcut icon"]', lambda { |el| el.attr('href') }],
                        ['link[@rel="icon"]', lambda { |el| el.attr('href') }])
      if url && url !~ /^http/ && @url
        url = URI.join(@url , url).to_s
      end
      
      url
    end
    
    # Returns URL of Web feed
    def feed
      url = @doc.match( ['link[@type="application/atom+xml"]', lambda { |el| el.attr('href') }],
                        ['link[@type="application/rss+xml"]', lambda { |el| el.attr('href') }]
      )
      
      if url && url !~ /^http/ && @url
        url = URI.join(@url , url).to_s
      end
      
      url
    end
  end
end