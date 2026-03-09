package com.httparena;

import org.eclipse.jetty.http2.server.HTTP2ServerConnectionFactory;
import org.eclipse.jetty.server.*;
import org.eclipse.jetty.util.ssl.SslContextFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.embedded.jetty.JettyServletWebServerFactory;
import org.springframework.boot.web.server.WebServerFactoryCustomizer;
import org.springframework.context.annotation.Bean;

import java.io.File;

@SpringBootApplication
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

    @Bean
    public WebServerFactoryCustomizer<JettyServletWebServerFactory> jettyCustomizer() {
        return factory -> factory.addServerCustomizers(server -> {
            File keystore = new File("/tmp/keystore.p12");
            if (!keystore.exists()) return;

            SslContextFactory.Server sslContextFactory = new SslContextFactory.Server();
            sslContextFactory.setKeyStorePath(keystore.getAbsolutePath());
            sslContextFactory.setKeyStorePassword("changeit");
            sslContextFactory.setKeyStoreType("PKCS12");
            sslContextFactory.setSniRequired(false);

            HttpConfiguration httpsConfig = new HttpConfiguration();
            httpsConfig.setSecureScheme("https");
            httpsConfig.setSecurePort(8443);
            httpsConfig.addCustomizer(new SecureRequestCustomizer(false));

            // HTTPS + HTTP/2 connector (TCP on 8443)
            SslConnectionFactory sslFactory = new SslConnectionFactory(sslContextFactory, "alpn");
            var alpn = new org.eclipse.jetty.alpn.server.ALPNServerConnectionFactory("h2", "http/1.1");
            HTTP2ServerConnectionFactory h2Factory = new HTTP2ServerConnectionFactory(httpsConfig);
            HttpConnectionFactory h1Factory = new HttpConnectionFactory(httpsConfig);
            ServerConnector h2Connector = new ServerConnector(server, sslFactory, alpn, h2Factory, h1Factory);
            h2Connector.setPort(8443);
            server.addConnector(h2Connector);

        });
    }
}
