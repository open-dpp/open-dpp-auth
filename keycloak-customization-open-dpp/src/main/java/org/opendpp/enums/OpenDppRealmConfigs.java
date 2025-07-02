package org.opendpp.enums;

public enum OpenDppRealmConfigs {
    REALM_NAME("open-dpp");

    private final String value;

    OpenDppRealmConfigs(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }
}
