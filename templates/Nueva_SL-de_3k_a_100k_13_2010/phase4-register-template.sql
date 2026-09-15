-- Phase 4: register template metadata and assign to acme organization (idempotent)
WITH target_org AS (
    SELECT id FROM organizations WHERE name = 'acme'
),
ins_template AS (
    INSERT INTO templates (name, description, version, filename)
    SELECT
        'Nueva_SL-de_3k_a_100k_13_2010',
        'Generated from Nueva_SL-de_3k_a_100k_13_2010.doc',
        2010,
        'Nueva_SL-de_3k_a_100k_13_2010.jinja2'
    WHERE NOT EXISTS (
        SELECT 1
        FROM templates
        WHERE name = 'Nueva_SL-de_3k_a_100k_13_2010'
          AND version = 2010
    )
    RETURNING id
),
template_row AS (
    SELECT id
    FROM templates
    WHERE name = 'Nueva_SL-de_3k_a_100k_13_2010'
      AND version = 2010
),
ins_mapping AS (
    INSERT INTO organization_templates (organization_id, template_id)
    SELECT o.id, t.id
    FROM target_org o
    CROSS JOIN template_row t
    WHERE NOT EXISTS (
        SELECT 1
        FROM organization_templates ot
        WHERE ot.organization_id = o.id
          AND ot.template_id = t.id
    )
    RETURNING organization_id, template_id
)
SELECT
    EXISTS(SELECT 1 FROM target_org) AS acme_exists,
    EXISTS(SELECT 1 FROM template_row) AS template_exists,
    COALESCE((SELECT COUNT(*) FROM ins_template), 0) AS templates_inserted,
    COALESCE((SELECT COUNT(*) FROM ins_mapping), 0) AS mappings_inserted;
