// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_digitalocean/otel_digitalocean.dart';

/// Traces DigitalOcean calls with OpenTelemetry.
///
/// `otel_digitalocean` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each DigitalOcean call in
/// [tracedDigitalOcean]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'digitalocean-example');

  // Wraps a DigitalOcean API call in a CLIENT span.
  final digitalOceanId = await tracedDigitalOcean<String>(
    operation: 'droplets.create',
    invoke: () async {
      // Make the DigitalOcean call here, then report what it returned.
      const id = 'digitalocean_8f3a2c';
      return const DigitalOceanCallResult(
          value: id,
          result: DigitalOceanResult(
              surface: 'droplets',
              region: 'nyc1',
              entityId: 'entity_8f3a2c',
              entityName: 'example',
              dropletSize: 's-1vcpu-1gb',
              dropletImage: 'ubuntu-24-04-x64',
              dropletStatus: 'new',
              spacesBucket: 'invoices',
              spacesObject: 'example',
              objectSizeBytes: 512,
              databaseEngine: 'pg',
              databaseVersion: '1',
              databaseStatus: 'creating',
              databaseSize: 'db-s-1vcpu-1gb',
              databaseNodes: 1,
              kubernetesVersion: '1',
              kubernetesNodePoolCount: 3,
              kubernetesAutoUpgrade: true,
              appSpec: 'example',
              appPhase: 'UNKNOWN',
              appBuildId: 'appbuild_8f3a2c',
              appDeploymentId: 'appdeployment_8f3a2c',
              appActiveDeploymentId: 'appactivedeployment_8f3a2c',
              functionName: 'example',
              functionRuntime: 'nodejs:20',
              loadBalancerAlgorithm: 'round_robin',
              loadBalancerProtocol: 'http',
              dnsType: 'A',
              dnsTtl: 1,
              rateLimitRemaining: 25,
              errorId: 'unauthorized',
              errorMessage: 'example',
              statusCode: 201));
    },
  );
  OTelLog.info('tracedDigitalOcean droplets.create returned $digitalOceanId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutDigitalOceanInstrumentationAsync.
  await runWithoutDigitalOceanInstrumentationAsync(
    () => tracedDigitalOcean<String>(
      operation: 'droplets.create',
      invoke: () async {
        const id = 'digitalocean_8f3a2c';
        return const DigitalOceanCallResult(
            value: id,
            result: DigitalOceanResult(
                surface: 'droplets',
                region: 'nyc1',
                entityId: 'entity_8f3a2c',
                entityName: 'example',
                dropletSize: 's-1vcpu-1gb',
                dropletImage: 'ubuntu-24-04-x64',
                dropletStatus: 'new',
                spacesBucket: 'invoices',
                spacesObject: 'example',
                objectSizeBytes: 512,
                databaseEngine: 'pg',
                databaseVersion: '1',
                databaseStatus: 'creating',
                databaseSize: 'db-s-1vcpu-1gb',
                databaseNodes: 1,
                kubernetesVersion: '1',
                kubernetesNodePoolCount: 3,
                kubernetesAutoUpgrade: true,
                appSpec: 'example',
                appPhase: 'UNKNOWN',
                appBuildId: 'appbuild_8f3a2c',
                appDeploymentId: 'appdeployment_8f3a2c',
                appActiveDeploymentId: 'appactivedeployment_8f3a2c',
                functionName: 'example',
                functionRuntime: 'nodejs:20',
                loadBalancerAlgorithm: 'round_robin',
                loadBalancerProtocol: 'http',
                dnsType: 'A',
                dnsTtl: 1,
                rateLimitRemaining: 25,
                errorId: 'unauthorized',
                errorMessage: 'example',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
