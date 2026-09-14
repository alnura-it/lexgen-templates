BEGIN;

INSERT INTO organizations (name)
VALUES ('acme')
ON CONFLICT (name) DO NOTHING;

INSERT INTO templates (name, description, version, filename)
VALUES (
    'Nueva_SL-de_3k_a_100k_13_2010',
    NULL,
    2010,
    'Nueva_SL-de_3k_a_100k_13_2010.jinja2'
)
ON CONFLICT ON CONSTRAINT uq_templates_name_version DO NOTHING;

INSERT INTO organization_templates (organization_id, template_id)
SELECT o.id, t.id
FROM organizations o
JOIN templates t
  ON t.name = 'Nueva_SL-de_3k_a_100k_13_2010'
 AND t.version = 2010
WHERE o.name = 'acme'
ON CONFLICT (organization_id, template_id) DO NOTHING;

COMMIT;
