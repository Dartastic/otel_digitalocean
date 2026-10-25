// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_digitalocean/otel_digitalocean.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_digitalocean-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('droplets.create records size + image + region', () async {
    await tracedDigitalOcean<String>(
      operation: 'droplets.create',
      invoke: () async => const DigitalOceanCallResult(
        value: 'ok',
        result: DigitalOceanResult(
          surface: 'droplets',
          region: 'nyc3',
          entityName: 'web-1',
          dropletSize: 's-2vcpu-2gb-amd',
          dropletImage: 'ubuntu-24-04-x64',
          dropletStatus: 'new',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('digitalocean droplets.create')!);
    expect(a['digitalocean.droplet.size'], 's-2vcpu-2gb-amd');
    expect(a['digitalocean.region'], 'nyc3');
  });

  test('apps.deployments.create ERROR phase sets span error', () async {
    await tracedDigitalOcean<String>(
      operation: 'apps.deployments.create',
      invoke: () async => const DigitalOceanCallResult(
        value: 'ok',
        result: DigitalOceanResult(
          surface: 'app_platform',
          appPhase: 'ERROR',
          appDeploymentId: 'd_1',
        ),
      ),
    );
    expect(
      spans.findSpanByName('digitalocean apps.deployments.create')!.status,
      SpanStatusCode.Error,
    );
  });

  test('databases.create records engine + node count', () async {
    await tracedDigitalOcean<String>(
      operation: 'databases.create',
      invoke: () async => const DigitalOceanCallResult(
        value: 'ok',
        result: DigitalOceanResult(
          surface: 'databases',
          databaseEngine: 'pg',
          databaseVersion: '16',
          databaseSize: 'db-s-2vcpu-4gb',
          databaseNodes: 3,
          databaseStatus: 'creating',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('digitalocean databases.create')!);
    expect(a['digitalocean.database.engine'], 'pg');
    expect(a['digitalocean.database.nodes'], 3);
  });

  test('rate_limit_exceeded sets span error', () async {
    await tracedDigitalOcean<String>(
      operation: 'droplets.list',
      invoke: () async => const DigitalOceanCallResult(
        value: 'ok',
        result: DigitalOceanResult(
          errorId: 'rate_limit_exceeded',
          statusCode: 429,
          rateLimitRemaining: 0,
        ),
      ),
    );
    expect(
      spans.findSpanByName('digitalocean droplets.list')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutDigitalOceanInstrumentationAsync(() async {
      await tracedDigitalOcean<String>(
        operation: 'account.get',
        invoke: () async => const DigitalOceanCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('digitalocean '), isEmpty);
  });
}
