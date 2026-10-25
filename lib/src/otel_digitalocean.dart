// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_digitalocean_suppression.dart';

const _tracerName = 'dartastic_otel_libs_digitalocean';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class DigitalOceanResult {
  /// Creates a result.
  const DigitalOceanResult({
    this.surface,
    this.region,
    this.entityId,
    this.entityName,
    this.dropletSize,
    this.dropletImage,
    this.dropletStatus,
    this.spacesBucket,
    this.spacesObject,
    this.objectSizeBytes,
    this.databaseEngine,
    this.databaseVersion,
    this.databaseStatus,
    this.databaseSize,
    this.databaseNodes,
    this.kubernetesVersion,
    this.kubernetesNodePoolCount,
    this.kubernetesAutoUpgrade,
    this.appSpec,
    this.appPhase,
    this.appBuildId,
    this.appDeploymentId,
    this.appActiveDeploymentId,
    this.functionName,
    this.functionRuntime,
    this.loadBalancerAlgorithm,
    this.loadBalancerProtocol,
    this.dnsType,
    this.dnsTtl,
    this.rateLimitRemaining,
    this.errorId,
    this.errorMessage,
    this.statusCode,
  });

  /// `droplets`, `spaces`, `databases`, `kubernetes`, `app_platform`,
  /// `functions`, `load_balancers`, `volumes`, `container_registry`,
  /// `dns`, `firewalls`, `floating_ips`, `images`, `snapshots`, `vpcs`,
  /// `monitoring`, `genai`, `account`, `billing`, `agent`.
  final String? surface;

  /// Region slug (`nyc1`, `nyc3`, `ams3`, `sfo3`, `sgp1`, `lon1`, ...).
  final String? region;

  /// Generic entity id (droplet/db/cluster/app/etc id).
  final String? entityId;
  final String? entityName;

  // ── Droplets ──────────────────────────────────────────────────
  /// `s-1vcpu-1gb`, `c-4`, `g-2vcpu-8gb`, `s-2vcpu-2gb-amd`, ...
  final String? dropletSize;

  /// Image slug (`ubuntu-24-04-x64`, `docker-20-04`, `cuda-11-6`, ...).
  final String? dropletImage;

  /// `new`, `active`, `off`, `archive`.
  final String? dropletStatus;

  // ── Spaces (S3-compatible) ────────────────────────────────────
  final String? spacesBucket;
  final String? spacesObject;
  final int? objectSizeBytes;

  // ── Managed Databases ─────────────────────────────────────────
  /// `pg`, `mysql`, `redis`, `mongodb`, `kafka`, `opensearch`.
  final String? databaseEngine;
  final String? databaseVersion;

  /// `creating`, `online`, `resizing`, `migrating`, `forking`.
  final String? databaseStatus;

  /// DB plan slug (`db-s-1vcpu-1gb`, ...).
  final String? databaseSize;
  final int? databaseNodes;

  // ── DOKS ──────────────────────────────────────────────────────
  final String? kubernetesVersion;
  final int? kubernetesNodePoolCount;
  final bool? kubernetesAutoUpgrade;

  // ── App Platform ──────────────────────────────────────────────
  /// Spec name field.
  final String? appSpec;

  /// `UNKNOWN`, `PENDING_BUILD`, `BUILDING`, `PENDING_DEPLOY`,
  /// `DEPLOYING`, `ACTIVE`, `SUPERSEDED`, `ERROR`, `CANCELED`.
  final String? appPhase;
  final String? appBuildId;
  final String? appDeploymentId;
  final String? appActiveDeploymentId;

  // ── Functions ─────────────────────────────────────────────────
  final String? functionName;

  /// `nodejs:20`, `python:3.11`, `go:1.22`, `php:8.2`, `swift:5`.
  final String? functionRuntime;

  // ── Load Balancers ────────────────────────────────────────────
  /// `round_robin`, `least_connections`.
  final String? loadBalancerAlgorithm;

  /// `http`, `https`, `http2`, `http3`, `tcp`, `udp`.
  final String? loadBalancerProtocol;

  // ── DNS ───────────────────────────────────────────────────────
  /// `A`, `AAAA`, `CNAME`, `MX`, `TXT`, `NS`, `SRV`, `CAA`.
  final String? dnsType;
  final int? dnsTtl;

  final int? rateLimitRemaining;

  /// DO API error id (`unauthorized`, `forbidden`, `not_found`,
  /// `unprocessable_entity`, `conflict`, `rate_limit_exceeded`,
  /// `server_error`).
  final String? errorId;
  final String? errorMessage;
  final int? statusCode;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class DigitalOceanCallResult<T> {
  /// Creates a call result.
  const DigitalOceanCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final DigitalOceanResult? result;
}

/// Wraps a DigitalOcean API call in a CLIENT span. [operation] is one of
/// `droplets.create`, `droplets.delete`, `droplets.list`, `droplets.get`,
/// `droplets.power.on`, `droplets.power.off`, `droplets.reboot`,
/// `droplets.resize`, `droplets.snapshot`,
/// `spaces.upload`, `spaces.download`, `spaces.delete`, `spaces.list`,
/// `spaces.copy`, `spaces.cdn.flush`, `databases.create`, `databases.delete`,
/// `databases.list`, `databases.get`, `databases.resize`,
/// `databases.firewall.update`, `databases.user.create`,
/// `databases.connectionPool.create`, `kubernetes.cluster.create`,
/// `kubernetes.cluster.delete`, `kubernetes.cluster.upgrade`,
/// `kubernetes.nodePool.create`, `kubernetes.nodePool.recycle`,
/// `kubernetes.nodePool.scale`, `kubernetes.kubeconfig.get`,
/// `apps.create`, `apps.update`, `apps.delete`, `apps.deployments.create`,
/// `apps.deployments.list`, `apps.deployments.cancel`,
/// `functions.invoke`, `functions.deploy`, `functions.namespace.create`,
/// `functions.namespace.delete`,
/// `loadBalancers.create`, `loadBalancers.delete`, `loadBalancers.list`,
/// `dns.record.create`, `dns.record.update`, `dns.record.delete`,
/// `dns.record.list`, `account.get`, `billing.history`, `cdn.flushCache`,
/// `images.list`, `snapshots.list`, `volumes.create`, `volumes.attach`,
/// `firewalls.create`, `containerRegistry.create`, `monitoring.alert.list`,
/// `genai.chat.completions`, `genai.embeddings`.
Future<T> tracedDigitalOcean<T>({
  required String operation,
  required Future<DigitalOceanCallResult<T>> Function() invoke,
}) async {
  if (digitalOceanInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'digitalocean',
    'rpc.method': operation,
    'digitalocean.operation': operation,
  };

  final span = _tracer().startSpan(
    'digitalocean $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.surface != null) {
        extras
            .add(OTelAPI.attributeString('digitalocean.surface', res.surface!));
      }
      if (res.region != null) {
        extras.add(OTelAPI.attributeString('digitalocean.region', res.region!));
      }
      if (res.entityId != null) {
        extras.add(OTelAPI.attributeString(
          'digitalocean.entity.id',
          res.entityId!,
        ));
      }
      if (res.entityName != null) {
        extras.add(OTelAPI.attributeString(
          'digitalocean.entity.name',
          res.entityName!,
        ));
      }
      if (res.dropletSize != null) {
        extras.add(OTelAPI.attributeString(
          'digitalocean.droplet.size',
          res.dropletSize!,
        ));
      }
      if (res.dropletImage != null) {
        extras.add(OTelAPI.attributeString(
          'digitalocean.droplet.image',
          res.dropletImage!,
        ));
      }
      if (res.dropletStatus != null) {
        extras.add(OTelAPI.attributeString(
          'digitalocean.droplet.status',
          res.dropletStatus!,
        ));
      }
      if (res.spacesBucket != null) {
        extras.add(OTelAPI.attributeString(
          'digitalocean.spaces.bucket',
          res.spacesBucket!,
        ));
      }
      if (res.spacesObject != null) {
        extras.add(OTelAPI.attributeString(
          'digitalocean.spaces.object',
          res.spacesObject!,
        ));
      }
      if (res.objectSizeBytes != null) {
        extras.add(OTelAPI.attributeInt(
          'digitalocean.spaces.object.size_bytes',
          res.objectSizeBytes!,
        ));
      }
      if (res.databaseEngine != null) {
        extras.add(OTelAPI.attributeString(
          'digitalocean.database.engine',
          res.databaseEngine!,
        ));
      }
      if (res.databaseVersion != null) {
        extras.add(OTelAPI.attributeString(
          'digitalocean.database.version',
          res.databaseVersion!,
        ));
      }
      if (res.databaseStatus != null) {
        extras.add(OTelAPI.attributeString(
          'digitalocean.database.status',
          res.databaseStatus!,
        ));
      }
      if (res.databaseSize != null) {
        extras.add(OTelAPI.attributeString(
          'digitalocean.database.size',
          res.databaseSize!,
        ));
      }
      if (res.databaseNodes != null) {
        extras.add(OTelAPI.attributeInt(
          'digitalocean.database.nodes',
          res.databaseNodes!,
        ));
      }
      if (res.kubernetesVersion != null) {
        extras.add(OTelAPI.attributeString(
          'digitalocean.k8s.version',
          res.kubernetesVersion!,
        ));
      }
      if (res.kubernetesNodePoolCount != null) {
        extras.add(OTelAPI.attributeInt(
          'digitalocean.k8s.node_pool.count',
          res.kubernetesNodePoolCount!,
        ));
      }
      if (res.kubernetesAutoUpgrade != null) {
        extras.add(OTelAPI.attributeBool(
          'digitalocean.k8s.auto_upgrade',
          res.kubernetesAutoUpgrade!,
        ));
      }
      if (res.appSpec != null) {
        extras.add(OTelAPI.attributeString(
          'digitalocean.app.spec',
          res.appSpec!,
        ));
      }
      if (res.appPhase != null) {
        extras.add(OTelAPI.attributeString(
          'digitalocean.app.phase',
          res.appPhase!,
        ));
        if (res.appPhase == 'ERROR' || res.appPhase == 'CANCELED') {
          span.setStatus(
            SpanStatusCode.Error,
            'DO app ${res.appPhase}',
          );
        }
      }
      if (res.appBuildId != null) {
        extras.add(OTelAPI.attributeString(
          'digitalocean.app.build_id',
          res.appBuildId!,
        ));
      }
      if (res.appDeploymentId != null) {
        extras.add(OTelAPI.attributeString(
          'digitalocean.app.deployment_id',
          res.appDeploymentId!,
        ));
      }
      if (res.appActiveDeploymentId != null) {
        extras.add(OTelAPI.attributeString(
          'digitalocean.app.active_deployment_id',
          res.appActiveDeploymentId!,
        ));
      }
      if (res.functionName != null) {
        extras.add(OTelAPI.attributeString(
          'digitalocean.function.name',
          res.functionName!,
        ));
      }
      if (res.functionRuntime != null) {
        extras.add(OTelAPI.attributeString(
          'digitalocean.function.runtime',
          res.functionRuntime!,
        ));
      }
      if (res.loadBalancerAlgorithm != null) {
        extras.add(OTelAPI.attributeString(
          'digitalocean.lb.algorithm',
          res.loadBalancerAlgorithm!,
        ));
      }
      if (res.loadBalancerProtocol != null) {
        extras.add(OTelAPI.attributeString(
          'digitalocean.lb.protocol',
          res.loadBalancerProtocol!,
        ));
      }
      if (res.dnsType != null) {
        extras.add(OTelAPI.attributeString(
          'digitalocean.dns.type',
          res.dnsType!,
        ));
      }
      if (res.dnsTtl != null) {
        extras.add(OTelAPI.attributeInt('digitalocean.dns.ttl', res.dnsTtl!));
      }
      if (res.rateLimitRemaining != null) {
        extras.add(OTelAPI.attributeInt(
          'digitalocean.rate_limit.remaining',
          res.rateLimitRemaining!,
        ));
      }
      if (res.errorId != null) {
        extras.add(OTelAPI.attributeString(
          'digitalocean.error.id',
          res.errorId!,
        ));
        span.setStatus(SpanStatusCode.Error, 'DO ${res.errorId}');
      }
      if (res.errorMessage != null) {
        extras.add(OTelAPI.attributeString(
          'digitalocean.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTelAPI.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(SpanStatusCode.Error, 'DO HTTP ${res.statusCode}');
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
