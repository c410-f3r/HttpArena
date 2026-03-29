package com.httparena;

import io.vertx.ext.web.Router;
import io.vertx.ext.web.handler.FileSystemAccess;
import io.vertx.ext.web.handler.StaticHandler;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.event.Observes;

/**
 * Serves the static resources in /data/static
 * Recommended way to do in production workloads (besides using a nginx sidecar).
 */
@ApplicationScoped
public class StaticFiles {

    void init(@Observes Router router) {
        var handler = StaticHandler.create(FileSystemAccess.ROOT, "/data/static");

        router.route("/static/*")
              .handler(handler);
    }

}
