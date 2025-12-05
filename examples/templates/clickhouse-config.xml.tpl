<clickhouse>
    <logger>
        <level>information</level>
        <log>{{ env "NOMAD_ALLOC_DIR" }}/logs/clickhouse-server.log</log>
        <errorlog>{{ env "NOMAD_ALLOC_DIR" }}/logs/clickhouse-server.err.log</errorlog>
        <size>1000M</size>
        <count>10</count>
    </logger>

    <http_port>{{ env "NOMAD_PORT_http" }}</http_port>
    <tcp_port>{{ env "NOMAD_PORT_native" }}</tcp_port>
    <interserver_http_port>{{ env "NOMAD_PORT_interserver" }}</interserver_http_port>

    <listen_host>0.0.0.0</listen_host>

    <path>{{ env "NOMAD_ALLOC_DIR" }}/data/</path>
    <tmp_path>{{ env "NOMAD_ALLOC_DIR" }}/tmp/</tmp_path>
    <user_files_path>{{ env "NOMAD_ALLOC_DIR" }}/user_files/</user_files_path>
    <format_schema_path>{{ env "NOMAD_ALLOC_DIR" }}/format_schemas/</format_schema_path>

    <users>
        <default>
            <password></password>
            <networks>
                <ip>::/0</ip>
            </networks>
            <profile>default</profile>
            <quota>default</quota>
        </default>
    </users>

    <profiles>
        <default>
            <max_memory_usage>10000000000</max_memory_usage>
            <use_uncompressed_cache>0</use_uncompressed_cache>
            <load_balancing>random</load_balancing>
        </default>
    </profiles>

    <quotas>
        <default>
            <interval>
                <duration>3600</duration>
                <queries>0</queries>
                <errors>0</errors>
                <result_rows>0</result_rows>
                <read_rows>0</read_rows>
                <execution_time>0</execution_time>
            </interval>
        </default>
    </quotas>
</clickhouse>
