#!/usr/bin/env python3
"""Generate apps/ios/SkyTrace.xcodeproj from the source tree.

This is a convenience generator so the project opens directly without XcodeGen.
XcodeGen (apps/ios/project.yml) remains the canonical, verified source; prefer
`make ios-project` when XcodeGen is installed. IDs are derived deterministically
from paths so regenerating produces a stable diff.

Usage:  python3 scripts/generate_xcodeproj.py
"""
import hashlib
import os

IOS = os.path.join(os.path.dirname(__file__), "..", "apps", "ios")
IOS = os.path.normpath(IOS)
APP = "SkyTrace"

def oid(*parts):
    h = hashlib.md5("::".join(parts).encode()).hexdigest().upper()
    return h[:24]

def swift_files(root):
    out = []
    for base, _, files in os.walk(root):
        for f in sorted(files):
            if f.endswith(".swift"):
                out.append(os.path.relpath(os.path.join(base, f), IOS))
    return sorted(out)

def resource_files():
    res = []
    for rel in ["SkyTrace/Resources/Assets.xcassets",
                "SkyTrace/Resources/Localizable.xcstrings",
                "SkyTrace/Resources/PrivacyInfo.xcprivacy",
                "SkyTrace.storekit"]:
        if os.path.exists(os.path.join(IOS, rel)):
            res.append(rel)
    return res

app_sources = swift_files(os.path.join(IOS, APP))
test_sources = swift_files(os.path.join(IOS, APP + "Tests"))
uitest_sources = swift_files(os.path.join(IOS, APP + "UITests"))
resources = resource_files()

# ---- object id assignment -------------------------------------------------
PROJECT = oid("project")
MAIN_GROUP = oid("group", "main")
PRODUCTS_GROUP = oid("group", "products")
FRAMEWORKS_GROUP = oid("group", "frameworks")

APP_TARGET = oid("target", APP)
TEST_TARGET = oid("target", "tests")
UITEST_TARGET = oid("target", "uitests")

APP_PRODUCT = oid("product", APP)
TEST_PRODUCT = oid("product", "tests")
UITEST_PRODUCT = oid("product", "uitests")

def phase_id(target, name): return oid("phase", target, name)
def cfg_list(scope, name): return oid("cfglist", scope, name)
def cfg(scope, name): return oid("cfg", scope, name)

def file_ref(path): return oid("fileref", path)
def build_file(target, path): return oid("buildfile", target, path)

# file type inference
def file_type(path):
    if path.endswith(".swift"): return "sourcecode.swift"
    if path.endswith(".xcassets"): return "folder.assetcatalog"
    if path.endswith(".xcstrings"): return "text.json.xcstrings"
    if path.endswith(".xcprivacy"): return "text.plist.xml"
    if path.endswith(".storekit"): return "text.json.xcstorekit"
    if path.endswith(".plist"): return "text.plist.xml"
    return "text"

# ---- build a tree of groups mirroring the folder structure ----------------
class Node:
    def __init__(self, name):
        self.name = name
        self.children = {}   # name -> Node (dirs)
        self.files = []      # list of rel paths

def insert(root, relpath):
    parts = relpath.split(os.sep)
    node = root
    for p in parts[:-1]:
        node = node.children.setdefault(p, Node(p))
    node.files.append(relpath)

tree = Node(".")
for p in app_sources + resources + test_sources + uitest_sources:
    insert(tree, p)

group_ids = {}
def group_id_for(path): return oid("group", path)

group_defs = []  # (id, name, path_or_none, child_ids)

def emit_group(node, node_path):
    child_ids = []
    for name in sorted(node.children):
        child = node.children[name]
        child_path = os.path.join(node_path, name) if node_path else name
        cid = group_id_for(child_path)
        emit_group(child, child_path)
        child_ids.append((cid, name))
    file_ids = []
    for f in sorted(node.files):
        file_ids.append((file_ref(f), os.path.basename(f)))
    gid = group_id_for(node_path) if node_path else MAIN_GROUP
    group_defs.append((gid, node.name if node_path else None,
                       node.name if node_path else None,
                       [c[0] for c in child_ids] + [f[0] for f in file_ids]))

# We emit app groups under a dedicated group and reference from main group.
emit_group(tree, "")

# ---- serialize ------------------------------------------------------------
L = []
def w(s=""): L.append(s)

w("// !$*UTF8*$!")
w("{")
w("\tarchiveVersion = 1;")
w("\tclasses = {")
w("\t};")
w("\tobjectVersion = 56;")
w("\tobjects = {")

# PBXBuildFile
w("\n/* Begin PBXBuildFile section */")
def emit_build_files(target, paths):
    for p in paths:
        bid = build_file(target, p)
        fid = file_ref(p)
        w(f"\t\t{bid} /* {os.path.basename(p)} */ = {{isa = PBXBuildFile; fileRef = {fid} /* {os.path.basename(p)} */; }};")
emit_build_files(APP_TARGET, app_sources)
emit_build_files(APP_TARGET, resources)
emit_build_files(TEST_TARGET, test_sources)
emit_build_files(UITEST_TARGET, uitest_sources)
w("/* End PBXBuildFile section */")

# PBXFileReference
w("\n/* Begin PBXFileReference section */")
seen_refs = set()
def emit_file_ref(path):
    fid = file_ref(path)
    if fid in seen_refs: return
    seen_refs.add(fid)
    name = os.path.basename(path)
    ft = file_type(path)
    w(f'\t\t{fid} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = {ft}; path = "{name}"; sourceTree = "<group>"; }};')
for p in app_sources + resources + test_sources + uitest_sources:
    emit_file_ref(p)
# products
w(f'\t\t{APP_PRODUCT} /* {APP}.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = {APP}.app; sourceTree = BUILT_PRODUCTS_DIR; }};')
w(f'\t\t{TEST_PRODUCT} /* {APP}Tests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = {APP}Tests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};')
w(f'\t\t{UITEST_PRODUCT} /* {APP}UITests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = {APP}UITests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};')
w("/* End PBXFileReference section */")

# PBXGroup — one unified tree (app + resources + tests + uitests).
w("\n/* Begin PBXGroup section */")

# root (MAIN_GROUP) children come from the group_defs entry for the synthetic root.
root_children = next(children for gid, _, _, children in group_defs if gid == MAIN_GROUP)

w(f"\t\t{MAIN_GROUP} = {{")
w("\t\t\tisa = PBXGroup;")
w("\t\t\tchildren = (")
for cid in root_children:
    w(f"\t\t\t\t{cid},")
w(f"\t\t\t\t{PRODUCTS_GROUP} /* Products */,")
w("\t\t\t);")
w("\t\t\tsourceTree = \"<group>\";")
w("\t\t};")

# all non-root groups
for gid, name, path, children in group_defs:
    if gid == MAIN_GROUP:
        continue
    w(f'\t\t{gid} /* {name} */ = {{')
    w("\t\t\tisa = PBXGroup;")
    w("\t\t\tchildren = (")
    for cid in children:
        w(f"\t\t\t\t{cid},")
    w("\t\t\t);")
    w(f'\t\t\tpath = "{name}";')
    w("\t\t\tsourceTree = \"<group>\";")
    w("\t\t};")

# products group
w(f"\t\t{PRODUCTS_GROUP} /* Products */ = {{")
w("\t\t\tisa = PBXGroup;")
w("\t\t\tchildren = (")
w(f"\t\t\t\t{APP_PRODUCT} /* {APP}.app */,")
w(f"\t\t\t\t{TEST_PRODUCT} /* {APP}Tests.xctest */,")
w(f"\t\t\t\t{UITEST_PRODUCT} /* {APP}UITests.xctest */,")
w("\t\t\t);")
w("\t\t\tname = Products;")
w("\t\t\tsourceTree = \"<group>\";")
w("\t\t};")
w("/* End PBXGroup section */")

# PBXSourcesBuildPhase / Resources / Frameworks
def emit_sources_phase(target, paths):
    pid = phase_id(target, "sources")
    w(f"\t\t{pid} /* Sources */ = {{")
    w("\t\t\tisa = PBXSourcesBuildPhase;")
    w("\t\t\tbuildActionMask = 2147483647;")
    w("\t\t\tfiles = (")
    for p in paths:
        w(f"\t\t\t\t{build_file(target, p)} /* {os.path.basename(p)} */,")
    w("\t\t\t);")
    w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
    w("\t\t};")
    return pid

def emit_resources_phase(target, paths):
    pid = phase_id(target, "resources")
    w(f"\t\t{pid} /* Resources */ = {{")
    w("\t\t\tisa = PBXResourcesBuildPhase;")
    w("\t\t\tbuildActionMask = 2147483647;")
    w("\t\t\tfiles = (")
    for p in paths:
        w(f"\t\t\t\t{build_file(target, p)} /* {os.path.basename(p)} */,")
    w("\t\t\t);")
    w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
    w("\t\t};")
    return pid

def emit_frameworks_phase(target):
    pid = phase_id(target, "frameworks")
    w(f"\t\t{pid} /* Frameworks */ = {{")
    w("\t\t\tisa = PBXFrameworksBuildPhase;")
    w("\t\t\tbuildActionMask = 2147483647;")
    w("\t\t\tfiles = (\n\t\t\t);")
    w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
    w("\t\t};")
    return pid

w("\n/* Begin PBXSourcesBuildPhase section */")
app_src_phase = emit_sources_phase(APP_TARGET, app_sources)
test_src_phase = emit_sources_phase(TEST_TARGET, test_sources)
uitest_src_phase = emit_sources_phase(UITEST_TARGET, uitest_sources)
w("/* End PBXSourcesBuildPhase section */")

w("\n/* Begin PBXResourcesBuildPhase section */")
app_res_phase = emit_resources_phase(APP_TARGET, resources)
w("/* End PBXResourcesBuildPhase section */")

w("\n/* Begin PBXFrameworksBuildPhase section */")
app_fw = emit_frameworks_phase(APP_TARGET)
test_fw = emit_frameworks_phase(TEST_TARGET)
uitest_fw = emit_frameworks_phase(UITEST_TARGET)
w("/* End PBXFrameworksBuildPhase section */")

# Target dependencies + container proxies for test targets
w("\n/* Begin PBXContainerItemProxy section */")
def emit_proxy(target):
    proxy = oid("proxy", target)
    w(f"\t\t{proxy} /* PBXContainerItemProxy */ = {{")
    w("\t\t\tisa = PBXContainerItemProxy;")
    w(f"\t\t\tcontainerPortal = {PROJECT} /* Project object */;")
    w("\t\t\tproxyType = 1;")
    w(f"\t\t\tremoteGlobalIDString = {APP_TARGET};")
    w(f'\t\t\tremoteInfo = {APP};')
    w("\t\t};")
    return proxy
test_proxy = emit_proxy(TEST_TARGET)
uitest_proxy = emit_proxy(UITEST_TARGET)
w("/* End PBXContainerItemProxy section */")

w("\n/* Begin PBXTargetDependency section */")
def emit_dep(target, proxy):
    dep = oid("dep", target)
    w(f"\t\t{dep} /* PBXTargetDependency */ = {{")
    w("\t\t\tisa = PBXTargetDependency;")
    w(f"\t\t\ttarget = {APP_TARGET} /* {APP} */;")
    w(f"\t\t\ttargetProxy = {proxy} /* PBXContainerItemProxy */;")
    w("\t\t};")
    return dep
test_dep = emit_dep(TEST_TARGET, test_proxy)
uitest_dep = emit_dep(UITEST_TARGET, uitest_proxy)
w("/* End PBXTargetDependency section */")

# Native targets
w("\n/* Begin PBXNativeTarget section */")
def emit_native(target, name, product_ref, product_name, product_type,
                phases, deps, cfglist):
    w(f"\t\t{target} /* {name} */ = {{")
    w("\t\t\tisa = PBXNativeTarget;")
    w(f"\t\t\tbuildConfigurationList = {cfglist} /* Build configuration list for PBXNativeTarget \"{name}\" */;")
    w("\t\t\tbuildPhases = (")
    for p in phases:
        w(f"\t\t\t\t{p},")
    w("\t\t\t);")
    w("\t\t\tbuildRules = (\n\t\t\t);")
    w("\t\t\tdependencies = (")
    for d in deps:
        w(f"\t\t\t\t{d},")
    w("\t\t\t);")
    w(f'\t\t\tname = {name};')
    w(f'\t\t\tproductName = {name};')
    w(f"\t\t\tproductReference = {product_ref} /* {product_name} */;")
    w(f'\t\t\tproductType = "{product_type}";')
    w("\t\t};")

emit_native(APP_TARGET, APP, APP_PRODUCT, f"{APP}.app", "com.apple.product-type.application",
            [app_src_phase, app_fw, app_res_phase], [], cfg_list("target", APP))
emit_native(TEST_TARGET, f"{APP}Tests", TEST_PRODUCT, f"{APP}Tests.xctest",
            "com.apple.product-type.bundle.unit-test",
            [test_src_phase, test_fw], [test_dep], cfg_list("target", "tests"))
emit_native(UITEST_TARGET, f"{APP}UITests", UITEST_PRODUCT, f"{APP}UITests.xctest",
            "com.apple.product-type.bundle.ui-testing",
            [uitest_src_phase, uitest_fw], [uitest_dep], cfg_list("target", "uitests"))
w("/* End PBXNativeTarget section */")

# Project object
w("\n/* Begin PBXProject section */")
w(f"\t\t{PROJECT} /* Project object */ = {{")
w("\t\t\tisa = PBXProject;")
w("\t\t\tattributes = {")
w("\t\t\t\tBuildIndependentTargetsInParallel = 1;")
w("\t\t\t\tLastSwiftUpdateCheck = 2600;")
w("\t\t\t\tLastUpgradeCheck = 2600;")
w("\t\t\t\tTargetAttributes = {")
w(f"\t\t\t\t\t{TEST_TARGET} = {{TestTargetID = {APP_TARGET};}};")
w(f"\t\t\t\t\t{UITEST_TARGET} = {{TestTargetID = {APP_TARGET};}};")
w("\t\t\t\t};")
w("\t\t\t};")
w(f"\t\t\tbuildConfigurationList = {cfg_list('project', 'proj')} /* Build configuration list for PBXProject */;")
w('\t\t\tcompatibilityVersion = "Xcode 14.0";')
w("\t\t\tdevelopmentRegion = ja;")
w("\t\t\thasScannedForEncodings = 0;")
w("\t\t\tknownRegions = (\n" + "".join(f"\t\t\t\t{r},\n" for r in ["ja","en","es","fr","de","\"pt-PT\"","\"zh-Hans\"","\"zh-Hant\"","ko","ar","hi","ru","Base"]) + "\t\t\t);")
w(f"\t\t\tmainGroup = {MAIN_GROUP};")
w(f"\t\t\tproductRefGroup = {PRODUCTS_GROUP} /* Products */;")
w("\t\t\tprojectDirPath = \"\";")
w("\t\t\tprojectRoot = \"\";")
w("\t\t\ttargets = (")
w(f"\t\t\t\t{APP_TARGET} /* {APP} */,")
w(f"\t\t\t\t{TEST_TARGET} /* {APP}Tests */,")
w(f"\t\t\t\t{UITEST_TARGET} /* {APP}UITests */,")
w("\t\t\t);")
w("\t\t};")
w("/* End PBXProject section */")

# Build configurations
w("\n/* Begin XCBuildConfiguration section */")

def project_base_settings(config):
    debug = config == "Debug"
    return {
        "ALWAYS_SEARCH_USER_PATHS": "NO",
        "CLANG_ANALYZER_NONNULL": "YES",
        "CLANG_ENABLE_MODULES": "YES",
        "CLANG_ENABLE_OBJC_ARC": "YES",
        "COPY_PHASE_STRIP": "NO",
        "ENABLE_STRICT_OBJC_MSGSEND": "YES",
        "GCC_C_LANGUAGE_STANDARD": "gnu11",
        "IPHONEOS_DEPLOYMENT_TARGET": "17.0",
        "MTL_ENABLE_DEBUG_INFO": ("INCLUDE_SOURCE" if debug else "NO"),
        "ONLY_ACTIVE_ARCH": ("YES" if debug else "NO"),
        "SDKROOT": "iphoneos",
        "SWIFT_VERSION": "6.0",
        "SWIFT_OPTIMIZATION_LEVEL": ("-Onone" if debug else "-O"),
        "SWIFT_STRICT_CONCURRENCY": "complete",
        "GCC_OPTIMIZATION_LEVEL": ("0" if debug else "s"),
        "ENABLE_TESTABILITY": ("YES" if debug else "NO"),
        "DEBUG_INFORMATION_FORMAT": ("dwarf" if debug else "dwarf-with-dsym"),
        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": ("DEBUG" if debug else ""),
        "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
    }

def app_settings(config):
    s = {
        "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
        "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
        "CODE_SIGN_STYLE": "Automatic",
        "CURRENT_PROJECT_VERSION": "1",
        "MARKETING_VERSION": "0.1.0",
        "GENERATE_INFOPLIST_FILE": "NO",
        "INFOPLIST_FILE": "SkyTrace/Resources/Info.plist",
        "IPHONEOS_DEPLOYMENT_TARGET": "17.0",
        "LD_RUNPATH_SEARCH_PATHS": "\"$(inherited) @executable_path/Frameworks\"",
        "PRODUCT_BUNDLE_IDENTIFIER": "com.example.skytrace",
        "PRODUCT_NAME": "\"$(TARGET_NAME)\"",
        "SWIFT_EMIT_LOC_STRINGS": "YES",
        "TARGETED_DEVICE_FAMILY": "\"1,2\"",
        "SWIFT_VERSION": "6.0",
    }
    if config == "Staging":
        s["PRODUCT_BUNDLE_IDENTIFIER"] = "com.example.skytrace.staging"
    return s

def test_settings(kind, config):
    s = {
        "CODE_SIGN_STYLE": "Automatic",
        "CURRENT_PROJECT_VERSION": "1",
        "MARKETING_VERSION": "0.1.0",
        "GENERATE_INFOPLIST_FILE": "YES",
        "IPHONEOS_DEPLOYMENT_TARGET": "17.0",
        "PRODUCT_NAME": "\"$(TARGET_NAME)\"",
        "SWIFT_VERSION": "6.0",
        "TARGETED_DEVICE_FAMILY": "\"1,2\"",
    }
    if kind == "unit":
        s["PRODUCT_BUNDLE_IDENTIFIER"] = "com.example.skytrace.tests"
        s["BUNDLE_LOADER"] = "\"$(TEST_HOST)\""
        s["TEST_HOST"] = "\"$(BUILT_PRODUCTS_DIR)/SkyTrace.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/SkyTrace\""
    else:
        s["PRODUCT_BUNDLE_IDENTIFIER"] = "com.example.skytrace.uitests"
        s["TEST_TARGET_NAME"] = APP
    return s

def emit_config(config_id, config_name, settings):
    w(f"\t\t{config_id} /* {config_name} */ = {{")
    w("\t\t\tisa = XCBuildConfiguration;")
    w("\t\t\tbuildSettings = {")
    import re as _re
    bare = _re.compile(r'^[A-Za-z0-9_$./]+$')  # OpenStep plist unquoted charset
    for k in sorted(settings):
        v = settings[k]
        if v == "":
            w(f'\t\t\t\t{k} = "";')
        elif v.startswith('"'):
            # already explicitly quoted by the caller — emit verbatim
            w(f"\t\t\t\t{k} = {v};")
        elif bare.match(v):
            w(f"\t\t\t\t{k} = {v};")
        else:
            w(f'\t\t\t\t{k} = "{v}";')
    w("\t\t\t};")
    w(f"\t\t\tname = {config_name};")
    w("\t\t};")

CONFIGS = ["Debug", "Staging", "Release"]
for c in CONFIGS:
    emit_config(cfg("project", c), c, project_base_settings(c))
    emit_config(cfg("app", c), c, app_settings(c))
    emit_config(cfg("tests", c), c, test_settings("unit", c))
    emit_config(cfg("uitests", c), c, test_settings("ui", c))
w("/* End XCBuildConfiguration section */")

# Configuration lists
w("\n/* Begin XCConfigurationList section */")
def emit_cfglist(list_id, label, scope):
    w(f"\t\t{list_id} /* Build configuration list for {label} */ = {{")
    w("\t\t\tisa = XCConfigurationList;")
    w("\t\t\tbuildConfigurations = (")
    for c in CONFIGS:
        w(f"\t\t\t\t{cfg(scope, c)} /* {c} */,")
    w("\t\t\t);")
    w("\t\t\tdefaultConfigurationIsVisible = 0;")
    w("\t\t\tdefaultConfigurationName = Release;")
    w("\t\t};")
emit_cfglist(cfg_list("project", "proj"), "PBXProject", "project")
emit_cfglist(cfg_list("target", APP), f'PBXNativeTarget "{APP}"', "app")
emit_cfglist(cfg_list("target", "tests"), f'PBXNativeTarget "{APP}Tests"', "tests")
emit_cfglist(cfg_list("target", "uitests"), f'PBXNativeTarget "{APP}UITests"', "uitests")
w("/* End XCConfigurationList section */")

w("\t};")
w(f"\trootObject = {PROJECT} /* Project object */;")
w("}")

proj_dir = os.path.join(IOS, f"{APP}.xcodeproj")
os.makedirs(proj_dir, exist_ok=True)
with open(os.path.join(proj_dir, "project.pbxproj"), "w") as fh:
    fh.write("\n".join(L) + "\n")

print(f"Wrote {proj_dir}/project.pbxproj")
print(f"  app sources: {len(app_sources)}  resources: {len(resources)}"
      f"  tests: {len(test_sources)}  uitests: {len(uitest_sources)}")

# ---- shared scheme (wires the local StoreKit configuration) ---------------
scheme_dir = os.path.join(proj_dir, "xcshareddata", "xcschemes")
os.makedirs(scheme_dir, exist_ok=True)

def buildable(target, name, product):
    return (f'<BuildableReference BuildableIdentifier="primary" '
            f'BlueprintIdentifier="{target}" BuildableName="{product}" '
            f'BlueprintName="{name}" ReferencedContainer="container:{APP}.xcodeproj">'
            f'</BuildableReference>')

scheme = f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="2600" version="1.7">
   <BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES">
      <BuildActionEntries>
         <BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">
            {buildable(APP_TARGET, APP, APP + ".app")}
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES">
      <Testables>
         <TestableReference skipped="NO">
            {buildable(TEST_TARGET, APP + "Tests", APP + "Tests.xctest")}
         </TestableReference>
         <TestableReference skipped="NO">
            {buildable(UITEST_TARGET, APP + "UITests", APP + "UITests.xctest")}
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES">
      <BuildableProductRunnable runnableDebuggingMode="0">
         {buildable(APP_TARGET, APP, APP + ".app")}
      </BuildableProductRunnable>
      <StoreKitConfigurationFileReference identifier="../{APP}.storekit"></StoreKitConfigurationFileReference>
   </LaunchAction>
   <ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES" savedToolIdentifier="" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES">
      <BuildableProductRunnable runnableDebuggingMode="0">
         {buildable(APP_TARGET, APP, APP + ".app")}
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction buildConfiguration="Debug"></AnalyzeAction>
   <ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"></ArchiveAction>
</Scheme>
'''
with open(os.path.join(scheme_dir, f"{APP}.xcscheme"), "w") as fh:
    fh.write(scheme)
print(f"Wrote shared scheme {scheme_dir}/{APP}.xcscheme")
