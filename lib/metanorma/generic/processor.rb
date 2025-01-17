require "metanorma/processor"

module Metanorma
  module Generic
    class Processor < Metanorma::Processor
      def configuration
        Metanorma::Generic.configuration
      end

      def initialize
        @short = configuration&.metanorma_name&.to_sym || :generic
        @input_format = :asciidoc
        @asciidoctor_backend = configuration&.metanorma_name&.to_sym || :generic
      end

      def output_formats
        super.merge(
          html: "html",
          doc: "doc",
        )
      end

      def version
        "Metanorma::Generic #{Metanorma::Generic::VERSION}"
      end

      def extract_options(file)
        head = file.sub(/\n\n.*$/m, "\n")
        ret = %w(htmlstylesheet htmlcoverpage htmlintropage scripts scripts-pdf
                 wordstylesheet standardstylesheet header wordcoverpage
                 wordintropage datauriimage htmltoclevels doctoclevels
                 ulstyle olstyle htmlstylesheet-override sectionsplit
                 wordstylesheet-override).each_with_object({}) do |w, acc|
          m = /\n:#{w}: ([^\n]+)\n/.match(head) or next
          acc[w.sub(/-/, "_").to_sym] = m[1]
        end
        super.merge(ret)
      end

      def output(isodoc_node, inname, outname, format, options={})
        case format
        when :html
          IsoDoc::Generic::HtmlConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :doc
          IsoDoc::Generic::WordConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :presentation
          IsoDoc::Generic::PresentationXMLConvert.new(options).convert(inname, isodoc_node, nil, outname)
        else
          super
        end
      end
    end
  end
end
