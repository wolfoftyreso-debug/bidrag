"""Manifesttester: parsebarhet + de driftinvarianter som inte far glida
(probes, non-root, pinnad datasetversion, interna endpoints ej exponerade)."""

import unittest
from pathlib import Path

import yaml

K8S = Path(__file__).parents[1] / "k8s"


def load_all(name: str) -> list[dict]:
    with (K8S / name).open(encoding="utf-8") as fh:
        return [doc for doc in yaml.safe_load_all(fh) if doc]


class ManifestTests(unittest.TestCase):
    def test_all_manifests_parse(self):
        for path in sorted(K8S.glob("*.yaml")):
            docs = load_all(path.name)
            self.assertTrue(docs, path.name)
            for doc in docs:
                self.assertIn("kind", doc, path.name)
                if doc["kind"] != "Kustomization":  # kustomization saknar metadata per design
                    self.assertIn("metadata", doc, path.name)

    def test_kustomization_lists_existing_resources(self):
        kust = load_all("kustomization.yaml")[0]
        for resource in kust["resources"]:
            self.assertTrue((K8S / resource).is_file(), resource)
        # secret-mallen far inte appliceras via kustomize
        self.assertNotIn("api-secret.template.yaml", kust["resources"])

    def test_deployment_invariants(self):
        dep = load_all("api-deployment.yaml")[0]
        pod = dep["spec"]["template"]["spec"]
        self.assertTrue(pod["securityContext"]["runAsNonRoot"])

        api = pod["containers"][0]
        self.assertIn("readinessProbe", api)
        self.assertIn("livenessProbe", api)
        self.assertIn("resources", api)
        self.assertTrue(api["securityContext"]["readOnlyRootFilesystem"])
        self.assertNotIn(":latest", api["image"])  # alltid pinnad tagg

        corpus_mount = next(m for m in api["volumeMounts"] if m["name"] == "corpus")
        self.assertTrue(corpus_mount.get("readOnly"), "corpus far aldrig skrivas av API:et")

    def test_corpus_version_is_pinned_in_git(self):
        config = load_all("api-configmap.yaml")[0]
        version = config["data"]["CORPUS_VERSION"]
        self.assertRegex(version, r"^corpus-v\d+\.\d+$")
        self.assertEqual(config["data"]["READER"], "null",
                         "reader byts forst nar en modell ar i PRODUCTION i registret")

    def test_ingress_exposes_only_public_surface(self):
        ingress = load_all("api-ingress.yaml")[0]
        paths = [p["path"] for rule in ingress["spec"]["rules"]
                 for p in rule["http"]["paths"]]
        self.assertIn("/v1/analyze", paths)
        for internal in ("/knowledge", "/verify", "/interpret", "/vision"):
            for exposed in paths:
                self.assertFalse(exposed.startswith(internal),
                                 f"intern endpoint {internal} far inte exponeras")

    def test_pdb_matches_deployment_labels(self):
        pdb = load_all("api-pdb.yaml")[0]
        dep = load_all("api-deployment.yaml")[0]
        self.assertEqual(pdb["spec"]["selector"]["matchLabels"],
                         dep["spec"]["selector"]["matchLabels"])


if __name__ == "__main__":
    unittest.main()
