# frozen_string_literal: true

def get_ismaster_doc
  add_clustertime_operationtime_okay_to_doc BSON::Document.new(
    ismaster: true,
    isMaster: true,
    isWritablePrimary: true,
    maxBsonObjectSize: 16777216,
    maxMessageSizeBytes: 48000000,
    maxWriteBatchSize: 100000,
    localTime: Time.now,
    maxWireVersion: 17, #2,
    minWireVersion: 0,
    helloOk: true,
    readOnly: false,
    topologyVersion: {
      counter: 0,
      processId: BSON::ObjectId.from_string('63ff58abbb09691e8f2d2ea4')
    },
    logicalSessionTimeoutMinutes: 30,
    connectionId: 1
  )

  # add_clustertime_operationtime_okay_to_doc BSON::Document.new(
  #   ismaster: true,
  #   isMaster: true,
  #   maxBsonObjectSize: 16777216,
  #   maxMessageSizeBytes: 48000000,
  #   maxWriteBatchSize: 100000,
  #   localTime: Time.now,
  #   maxWireVersion: 17, #2,
  #   minWireVersion: 0,
  #   helloOk: true,
  #   topologyVersion: {
  #     counter: 0,
  #     processId: BSON::ObjectId.from_string('63ff58abbb09691e8f2d2ea4')
  #   },
  #   logicalSessionTimeoutMinutes: 30,
  #   connectionId: 1
  # )

  # BSON::Document.new(
  #   ismaster: true,
  #   maxBsonObjectSize: 16777216,
  #   maxMessageSizeBytes: 48000000,
  #   maxWriteBatchSize: 100000,
  #   localTime: Time.now.utc,
  #   logicalSessionTimeoutMinutes: 30,
  #   connectionId: 1,
  #   minWireVersion: 0,
  #   maxWireVersion: 8,
  #   readOnly: false,
  #   ok: 1.0
  # )
end

def get_buildinfo_doc
  add_clustertime_operationtime_okay_to_doc BSON::Document.new(
    version: "4.2.2",
    gitVersion: "a0bbbff6ada159e19298d37946ac8dc4b497eadf",
    modules: ["enterprise"],
    allocator: "system",
    javascriptEngine: "mozjs",
    sysInfo: "deprecated",
    versionArray: [4, 2, 2, 0],
    openssl: {
      running: "Apple Secure Transport"
    },
    buildEnvironment: {
      distmod: "",
      distarch: "x86_64",
      cc: "/Applications/Xcode10.2.0.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang: Apple LLVM version 10.0.1 (clang-1001.0.46.3)",
      ccflags: "-isysroot /Applications/Xcode10.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.14.sdk -mmacosx-version-min=10.12 -target darwin16.0.0 -arch x86_64 -fno-omit-frame-pointer -fno-strict-aliasing -ggdb -pthread -Wall -Wsign-compare -Wno-unknown-pragmas -Winvalid-pch -Werror -O2 -Wno-unused-local-typedefs -Wno-unused-function -Wno-unused-private-field -Wno-deprecated-declarations -Wno-tautological-constant-out-of-range-compare -Wno-tautological-constant-compare -Wno-tautological-unsigned-zero-compare -Wno-tautological-unsigned-enum-zero-compare -Wno-unused-const-variable -Wno-missing-braces -Wno-inconsistent-missing-override -Wno-potentially-evaluated-expression -Wno-unused-lambda-capture -Wno-exceptions -Wunguarded-availability -fstack-protector-strong -fno-builtin-memcmp",
      cxx: "/Applications/Xcode10.2.0.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++: Apple LLVM version 10.0.1 (clang-1001.0.46.3)",
      cxxflags: "-Woverloaded-virtual -Werror=unused-result -Wpessimizing-move -Wredundant-move -Wno-undefined-var-template -Wno-instantiation-after-specialization -fsized-deallocation -stdlib=libc++ -std=c++17",
      linkflags: "-Wl,-syslibroot,/Applications/Xcode10.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.14.sdk -mmacosx-version-min=10.12 -target darwin16.0.0 -arch x86_64 -Wl,-bind_at_load -Wl,-fatal_warnings -fstack-protector-strong -stdlib=libc++",
      target_arch: "x86_64",
      target_os: "macOS"
    },
    bits: 64,
    debug: false,
    maxBsonObjectSize: 16777216,
    storageEngines: ["biggie", "devnull", "ephemeralForTest", "inMemory", "queryable_wt", "wiredTiger"]
  )
end

def get_listdatabases_doc
  add_clustertime_operationtime_okay_to_doc BSON::Document.new(
    "databases": [
      {"name": "admin", "sizeOnDisk": 262144.0, "empty": false},
      {"name": "config", "sizeOnDisk": 110592.0, "empty": false},
      {"name": "local", "sizeOnDisk": 73728.0, "empty": false},
      {"name": "test", "sizeOnDisk": 40960.0, "empty": false}
    ],
    "totalSize": 487424.0
  )
end


def get_listcollections_doc
  add_clustertime_operationtime_okay_to_doc BSON::Document.new(
    "cursor": {
      "id": 0,
      "ns": "admin.$cmd.listCollections",
      "firstBatch": [
        {"name": "system.users", "type": "collection"},
        {"name": "system.roles", "type": "collection"},
        {"name": "system.version", "type": "collection"}
      ]
    }
  )
end


def get_getlog_doc
  add_clustertime_operationtime_okay_to_doc BSON::Document.new(
    totalLinesWritten: 0,
    log: []
  )
end


def get_freemonitoringstatus_doc
  add_clustertime_operationtime_okay_to_doc BSON::Document.new(
    state: "undecided"
  )
end


def get_hostinfo_doc
  add_clustertime_operationtime_okay_to_doc BSON::Document.new(
    system: {
      currentTime: Time.now,
      hostname: "todo-get-hostname",
      cpuAddrSize: 64,
      memSizeMB: 16384,
      memLimitMB: 16384,
      numCores: 10,
      cpuArch: "x86_64",
      numaEnabled: false
    },
    os: {
      type: "Darwin",
      name: "Mac OS X",
      version: "22.3.0"
    },
    extra: {
      extra: {
        versionString: "Darwin Kernel Version 22.3.0: Mon Jan 30 20:38:37 PST 2023; root:xnu-8792.81.3~2/RELEASE_ARM64_T6000",
        alwaysFullSync: 0,
        nfsAsync: 0,
        model: "MacBookPro18,1",
        physicalCores: 10,
        cpuFrequencyMHz: 2400,
        cpuString: "Apple M1 Pro",
        cpuFeatures: "FPU VME DE PSE TSC MSR PAE MCE CX8 APIC SEP MTRR PGE MCA CMOV PAT PSE36 CLFSH DS ACPI MMX FXSR SSE SSE2 SS HTT TM PBE SSE3 PCLMULQDQ DTSE64 MON DSCPL VMX EST TM2 SSSE3 CX16 TPR PDCM SSE4.1 SSE4.2 AES SEGLIM64",
        pageSize: 4096,
        scheduler: "edge"
      }
    }
  )
end


def get_dbstats_doc
  add_clustertime_operationtime_okay_to_doc BSON::Document.new(
    db: 'admin',
    collections: 1,
    views: 0,
    objects: 1,
    avgObjSize: 4,
    dataSize: 4,
    storageSize: 4,
    indexes: 1,
    indexSize: 4,
    totalSize: 8,
    scaleFactor: 1,
    fsUsedSize: 4,
    fsTotalSize: 10
  )
end


def get_connectionstatus_doc
  add_clustertime_operationtime_okay_to_doc BSON::Document.new(
    authInfo: {
      authenticatedUsers: [],
      authenticatedUserRoles: [],
      authenticatedUserPrivileges: []
    }
  )
end


def get_getparameter_doc
  add_clustertime_operationtime_okay_to_doc BSON::Document.new(
    featureCompatibilityVersion: {
      version: "4.2"
    }
  )
end


def get_ping_doc
  add_clustertime_operationtime_okay_to_doc BSON::Document.new(
  )
end


def get_find_doc(req_doc)
  add_clustertime_operationtime_okay_to_doc BSON::Document.new(
    cursor: {
      firstBatch: [
        {
          '_id': 1,
          name: "Nitin"
        }
      ],
      id: 0,
      ns: "#{req_doc['$db']}.#{req_doc['find']}"
    }
  )
end


def add_clustertime_operationtime_okay_to_doc(doc)
  doc[:ok] = 1.0
  doc['$clusterTime'] = {
    clusterTime: BSON::Timestamp.new(Time.now.to_i, 0), #Time.now
    signature: {
      hash: "\0\0\0\0",  #TODO How is this hash generated?
      keyId: 6838625487661563906  #TODO How is this keyId generated?
    }
  }
  doc[:operationTime] = Time.now
  doc
end

