module KubernetesCert

  BASE_PATH ||= '/etc/kubernetes/ssl'

  class Generator
    attr_reader :dbag, :root_cn

    include Dbag

    def initialize(data_bag, data_bag_item, root_cn)
      @dbag = Dbag::Keystore.new(data_bag, data_bag_item)
      @root_cn = root_cn
    end


    def root_key
      @root_key ||= key("#{root_cn}_key")
    end

    def node_key(cn)
      key("#{cn}_key")
    end


    def root_ca
      return @root_ca unless @root_ca.nil?

      ca_pem = dbag.get(root_cn)

      if !ca_pem.nil?
        @root_ca = OpenSSL::X509::Certificate.new(ca_pem)
        return @root_ca

      else
        @root_ca = OpenSSL::X509::Certificate.new
        @root_ca.version = 2
        @root_ca.serial = 1

        @root_ca.subject = OpenSSL::X509::Name.new([
          ["CN", root_cn]
        ])
        @root_ca.issuer = @root_ca.subject
        @root_ca.public_key = root_key.public_key

        @root_ca.not_before = Time.new
        @root_ca.not_after = ca.not_before + 63072000

        @root_ca.sign(root_key, OpenSSL::Digest::SHA256.new)

        dbag.put(root_cn, @root_ca.to_pem)
        return @root_ca
      end
    end


    def node_cert(cn, alt_names)
      node_pem = dbag.get(cn)

      if !node_pem.nil?
        return OpenSSL::X509::Certificate.new(node_pem)

      else
        cert = OpenSSL::X509::Certificate.new
        cert.version = 2
        cert.serial = 2

        cert.subject = OpenSSL::X509::Name.new([
          ["CN", cn]
        ])
        cert.issuer = root_ca.subject
        cert.public_key = node_key(cn).public_key

        cert.not_before = Time.new
        cert.not_after = ca.not_before + 63072000

        ef = OpenSSL::X509::ExtensionFactory.new
        ef.subject_certificate = cert
        ef.issuer_certificate = root_ca
        ef.config['alt_names'] = alt_names

        cert.add_extension(ef.create_extension("basicConstraints", "CA:FALSE", true))
        cert.add_extension(ef.create_extension("keyUsage", 'nonRepudiation, digitalSignature, keyEncipherment', true))
        cert.add_extension(ef.create_extension("subjectAltName", '@alt_names', true))

        cert.sign(root_key, OpenSSL::Digest::SHA256.new)

        dbag.put(cn, cert.to_pem)
        return cert
      end
    end


    def admin_cert(cn)
      admin_pem = dbag.get(cn)

      if !admin_pem.nil?
        return OpenSSL::X509::Certificate.new(admin_pem)

      else
        cert = OpenSSL::X509::Certificate.new
        cert.version = 2
        cert.serial = 2

        cert.subject = OpenSSL::X509::Name.new([
          ["CN", cn]
        ])
        cert.issuer = root_ca.subject
        cert.public_key = node_key(cn).public_key

        cert.not_before = Time.new
        cert.not_after = ca.not_before + 63072000

        cert.sign(root_key, OpenSSL::Digest::SHA256.new)
        return cert
      end
    end


    private

    def key(label)
      key_pem = dbag.get(label)

      if !key_pem.nil?
        return OpenSSL::PKey::RSA.new(key_pem)

      else
        key = OpenSSL::PKey::RSA.new(2048)
        dbag.put(label, key.to_pem)

        return key
      end
    end
  end
end
