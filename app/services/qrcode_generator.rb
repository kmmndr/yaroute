class QrcodeGenerator
  attr_accessor :url, :filename

  def initialize(url, extension = 'svg')
    self.url = url
    self.filename = Rails.root.join('tmp', 'qrcodes', "#{url.parameterize}.#{extension}")

    create_image # unless File.exist?(filename)
  end

  def extension
    File.extname(filename)
  end

  def create_image
    qrcode = RQRCode::QRCode.new(url)

    FileUtils.mkdir_p(File.dirname(filename))

    case extension
    when '.png'
      png = qrcode.as_png(
        bit_depth: 1,
        border_modules: 1,
        color_mode: ChunkyPNG::COLOR_GRAYSCALE,
        color: 'black',
        file: nil, # filename,
        fill: 'white',
        module_px_size: 6,
        resize_exactly_to: false,
        resize_gte_to: false,
        size: 300
      )
      IO.binwrite(filename, png.to_s)
    when '.svg'
      svg = qrcode.as_svg(
        color: '000',
        shape_rendering: 'crispEdges',
        module_size: 6,
        standalone: true,
        use_path: true
      )
      IO.binwrite(filename, svg)
    else
      raise
    end
  end

  def image_data
    @data ||= Base64.strict_encode64(File.read(filename))
  end

  def image_tag
    data_mime = case extension
                when '.png'
                  'data:image/png;base64'
                when '.svg'
                  'data:image/svg+xml;base64'
                else
                end

    "#{data_mime},#{image_data}"
  end
end
