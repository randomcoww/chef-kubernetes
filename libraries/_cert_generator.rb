module KubernetesCert

  BASE_PATH ||= '/etc/kubernetes/ssl'

  class CertGenerator
    attr_reader :dbag

    include Dbag

    def initialize(data_bag, data_bag_item)
      @dbag = Dbag::Keystore.new(data_bag, data_bag_item)
    end


    def root_key
      return @root_key unless @root_key.nil?

      key_pem = dbag.get('root_key')

      if !key_pem.nil?
        @root_key = OpenSSL::PKey::RSA.new(key_pem)
        return @root_key

      else
        @root_key = OpenSSL::PKey::RSA.new(2048)
        dbag.put('root_key', @root_key.to_pem)

        return @root_key
      end
    end

    def root_ca
      return @root_ca unless @root_ca.nil?

      ca_pem = dbag.get('root_ca')

      if !ca_pem.nil?
        @root_ca = OpenSSL::X509::Certificate.new(ca_pem)
        return @root_ca

      else
        @root_ca = OpenSSL::X509::Certificate.new
        @root_ca.version = 2
        @root_ca.serial = 1

        @root_ca.subject = OpenSSL::X509::Name.new([
          ["CN", 'root_ca']
        ])
        @root_ca.issuer = @root_ca.subject
        @root_ca.public_key = root_key.public_key

        @root_ca.not_before = Time.new
        @root_ca.not_after = @root_ca.not_before + 63072000

        @root_ca.sign(root_key, OpenSSL::Digest::SHA256.new)

        dbag.put('root_ca', @root_ca.to_pem)
        return @root_ca
      end
    end


    def key
      OpenSSL::PKey::RSA.new(2048)
    end

    def node_cert(cn, key, extensions={}, alt_names={})
      cert = OpenSSL::X509::Certificate.new
      cert.version = 2
      cert.serial = 2

      cert.subject = OpenSSL::X509::Name.new([
        ["CN", cn]
      ])
      cert.issuer = root_ca.subject
      cert.public_key = key.public_key

      cert.not_before = Time.new
      cert.not_after = cert.not_before + 63072000

      ef = OpenSSL::X509::ExtensionFactory.new
      ef.subject_certificate = cert
      ef.issuer_certificate = root_ca
      ef.config = OpenSSL::Config.load(OpenSSL::Config::DEFAULT_CONFIG_FILE)

      if !alt_names.empty?
        ef.config['alt_names'] = alt_names
      end

      extensions.each_pair do |k, v|
        cert.add_extension(ef.create_extension(k, v, true))
      end

      cert.sign(root_key, OpenSSL::Digest::SHA256.new)
      return cert
    end
  end
end
