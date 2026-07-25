import argparse
import os
import re
import zipfile


MISSION_FILE = "Kola Range.miz"


MISSION_SERVICES = [
    ("AWACS", "Wizard", "250.000 AM", "CVN recovery AWACS", "TACAN: n/a", "ICLS: n/a", "LINK4/ACLS: not configured in mission scripts"),
    ("AWACS", "Darkstar", "249.000 AM", "Blue C3I AWACS", "TACAN: n/a", "ICLS: n/a", "LINK4/ACLS: not configured in mission scripts"),
    ("AAR", "Navy One", "252.500 AM", "CVN recovery tanker", "TACAN: 1Y RCV", "ICLS: n/a", "LINK4/ACLS: n/a"),
    ("AAR", "Texaco One", "252.300 AM", "Boom tanker", "TACAN: 52Y TX1", "ICLS: n/a", "LINK4/ACLS: n/a"),
    ("AAR", "Shell One", "252.100 AM", "Probe-and-drogue tanker", "TACAN: 51Y SH1", "ICLS: n/a", "LINK4/ACLS: n/a"),
    ("CARRIER", "CVN-75", "127.500 AM DCS ATC", "Supercarrier", "TACAN: 75X CVN", "ICLS: 11 C75", "LINK4/ACLS: not configured in mission scripts"),
    ("CARRIER", "LHA-1", "128.500 AM DCS ATC", "Amphibious assault ship", "TACAN: 51X LHA", "ICLS: 13 LHA", "LINK4/ACLS: not configured in mission scripts"),
]


CARRIER_BUTTONS = {
    "CVN-75": [
        (1, "260.000 AM", "Tower / Paddles / LSO"),
        (2, "260.100 AM", "Departure"),
        (3, "249.100 AM", "Strike"),
        (4, "258.200 AM", "Red Crown"),
        (15, "260.200 AM", "CCA Final A"),
        (16, "260.300 AM", "Marshal / AIRBOSS"),
        (17, "260.400 AM", "CCA Final B"),
    ],
    "LHA-1": [
        (1, "261.000 AM", "Tower / Paddles / LSO"),
        (16, "261.300 AM", "Marshal / AIRBOSS"),
    ],
}


FREQUENCY_LABELS = {
    "38.700": "TOWER EFRO VHF/LOW",
    "38.800": "TOWER BAS100 VHF/LOW",
    "38.950": "TOWER ENBO VHF/LOW",
    "118.250": "TOWER BAS100 VHF",
    "118.300": "TOWER ENBO VHF",
    "118.700": "TOWER EFRO VHF",
    "121.500": "GUARD VHF",
    "126.250": "ATIS BAS100",
    "126.700": "ATIS EFRO",
    "126.900": "ATIS ENBO",
    "127.500": "CVN-75 DCS ATC",
    "128.500": "LHA-1 DCS ATC",
    "156.800": "MARITIME CH16",
    "243.000": "GUARD UHF",
    "249.000": "AWACS DARKSTAR",
    "249.100": "CVN-75 BTN3 STRIKE",
    "250.000": "AWACS WIZARD",
    "250.250": "TOWER EFRO UHF",
    "250.450": "TOWER ENBO UHF",
    "252.100": "AAR SHELL ONE",
    "252.300": "AAR TEXACO ONE",
    "252.500": "AAR NAVY ONE",
    "256.000": "TOWER FARP WARSAW UHF",
    "257.100": "TOWER BAS100 UHF",
    "258.200": "CVN-75 BTN4 RED CROWN",
    "260.000": "CVN-75 BTN1 TOWER/LSO",
    "260.100": "CVN-75 BTN2 DEPARTURE",
    "260.200": "CVN-75 BTN15 CCA FINAL A",
    "260.300": "CVN-75 BTN16 MARSHAL",
    "260.400": "CVN-75 BTN17 CCA FINAL B",
    "261.000": "LHA-1 BTN1 TOWER/LSO",
    "261.300": "LHA-1 BTN16 MARSHAL",
    "266.200": "FLIGHT VFMA-212 1 UHF",
    "266.250": "FLIGHT VFMA-212 2 UHF",
    "266.800": "FLIGHT VFMA-212 3 UHF",
}


COMMON_FREQUENCY_NAMES = [
    "ANNA",
    "BARBARA",
    "CELINA",
    "DIANA",
    "EWA",
    "FLORA",
    "GABRIELA",
    "HELENA",
    "IRENA",
    "JULIA",
    "KAROLINA",
    "LENA",
    "MARIA",
    "NATALIA",
    "OLGA",
    "PAULINA",
    "RENATA",
    "SABINA",
    "TERESA",
    "URSZULA",
    "WANDA",
    "ZOFIA",
]


def normalize_frequency(frequency):
    try:
        return "{:.3f}".format(float(frequency))
    except ValueError:
        return str(frequency)


def match_brace(text, open_index):
    depth = 0
    in_string = False
    escaped = False
    for index in range(open_index, len(text)):
        char = text[index]
        if in_string:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
        else:
            if char == '"':
                in_string = True
            elif char == "{":
                depth += 1
            elif char == "}":
                depth -= 1
                if depth == 0:
                    return index
    raise ValueError("Unmatched brace in mission file")


def table_entries(block):
    entries = []
    offset = 0
    while True:
        match = re.search(r"\[(\d+)\]\s*=\s*\{", block[offset:])
        if not match:
            break
        start = offset + match.end() - 1
        end = match_brace(block, start)
        entries.append((int(match.group(1)), block[start : end + 1]))
        offset = end + 1
    return entries


def string_field(block, name):
    match = re.search(r'\["' + re.escape(name) + r'"\]\s*=\s*"((?:\\.|[^"\\])*)"', block)
    return match.group(1) if match else ""


def number_field(block, name):
    match = re.search(r'\["' + re.escape(name) + r'"\]\s*=\s*([-0-9.]+)', block)
    return match.group(1) if match else ""


def top_string_field(block, name):
    target = '["{}"]'.format(name)
    depth = 0
    in_string = False
    escaped = False
    index = 0
    while index < len(block):
        char = block[index]
        if in_string:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
            index += 1
            continue
        if char == '"':
            in_string = True
            index += 1
            continue
        if char == "{":
            depth += 1
            index += 1
            continue
        if char == "}":
            depth -= 1
            index += 1
            continue
        if depth == 1 and block.startswith(target, index):
            match = re.match(r'\["' + re.escape(name) + r'"\]\s*=\s*"((?:\\.|[^"\\])*)"', block[index:])
            if match:
                return match.group(1)
        index += 1
    return ""


def parse_channels(unit_block):
    radio_match = re.search(r'\["Radio"\]\s*=\s*\{', unit_block)
    if not radio_match:
        return []

    start = radio_match.end() - 1
    end = match_brace(unit_block, start)
    radio_block = unit_block[start : end + 1]
    radios = []

    for radio_id, radio_entry in table_entries(radio_block):
        channel_match = re.search(r'\["channels"\]\s*=\s*\{', radio_entry)
        channels = []
        if channel_match:
            channel_start = channel_match.end() - 1
            channel_end = match_brace(radio_entry, channel_start)
            channel_block = radio_entry[channel_start : channel_end + 1]
            for channel, frequency in re.findall(r"\[(\d+)\]\s*=\s*([-0-9.]+)", channel_block):
                channels.append((int(channel), frequency))
        radios.append((radio_id, sorted(channels)))
    return radios


def safe_filename(name):
    safe = re.sub(r"[^A-Za-z0-9_.-]+", "_", name.strip())
    return safe.strip("._") or "unnamed"


def load_mission_text(miz_path):
    with zipfile.ZipFile(miz_path) as archive:
        return archive.read("mission").decode("utf-8", "ignore")


def iter_air_groups(mission_text):
    for category_match in re.finditer(r'\["(plane|helicopter)"\]\s*=\s*\{', mission_text):
        category = category_match.group(1)
        category_start = category_match.end() - 1
        category_end = match_brace(mission_text, category_start)
        category_block = mission_text[category_start : category_end + 1]
        group_match = re.search(r'\["group"\]\s*=\s*\{', category_block)
        if not group_match:
            continue
        group_start = group_match.end() - 1
        group_end = match_brace(category_block, group_start)
        for _, group_block in table_entries(category_block[group_start : group_end + 1]):
            yield category, group_block


def group_units(group_block):
    units_match = re.search(r'\["units"\]\s*=\s*\{', group_block)
    if not units_match:
        return []
    start = units_match.end() - 1
    end = match_brace(group_block, start)
    units_block = group_block[start : end + 1]
    return [unit_block for _, unit_block in table_entries(units_block)]


def collect_group_frequency_keys(group_block):
    keys = set()
    for unit_block in group_units(group_block):
        for _, channels in parse_channels(unit_block):
            for _, frequency in channels:
                keys.add(normalize_frequency(frequency))
    return keys


def collect_common_frequency_labels(groups):
    frequency_groups = {}
    for _, group_block in groups:
        group_name = top_string_field(group_block, "name") or string_field(group_block, "name")
        for frequency in collect_group_frequency_keys(group_block):
            if frequency not in FREQUENCY_LABELS:
                frequency_groups.setdefault(frequency, set()).add(group_name)

    labels = {}
    common = sorted(
        (frequency for frequency, group_names in frequency_groups.items() if len(group_names) > 1),
        key=lambda value: float(value),
    )
    for index, frequency in enumerate(common):
        name = COMMON_FREQUENCY_NAMES[index % len(COMMON_FREQUENCY_NAMES)]
        suffix = index // len(COMMON_FREQUENCY_NAMES)
        labels[frequency] = name if suffix == 0 else "{}{}".format(name, suffix + 1)
    return labels


def frequency_label(frequency, common_labels):
    key = normalize_frequency(frequency)
    if key in FREQUENCY_LABELS:
        return FREQUENCY_LABELS[key]
    if key in common_labels:
        return "COMMON {}".format(common_labels[key])
    return ""


def write_group_report(output_dir, category, group_block, common_labels):
    group_name = top_string_field(group_block, "name") or string_field(group_block, "name")
    group_frequency = number_field(group_block, "frequency")
    units = group_units(group_block)

    lines = []
    lines.append("GROUP: {}".format(group_name))
    lines.append("CATEGORY: {}".format(category))
    if group_frequency:
        lines.append("GROUP_FREQUENCY: {}".format(group_frequency))
    lines.append("")

    has_radio = False
    for unit_index, unit_block in enumerate(units, 1):
        unit_name = top_string_field(unit_block, "name") or string_field(unit_block, "name")
        unit_type = string_field(unit_block, "type")
        skill = string_field(unit_block, "skill")
        radios = parse_channels(unit_block)

        lines.append("UNIT {}: {}".format(unit_index, unit_name))
        lines.append("TYPE: {}".format(unit_type))
        lines.append("SKILL: {}".format(skill))
        if not radios:
            lines.append("RADIO: none")
        for radio_id, channels in radios:
            has_radio = True
            lines.append("RADIO {}:".format(radio_id))
            if not channels:
                lines.append("  no channels")
            for channel, frequency in channels:
                label = frequency_label(frequency, common_labels)
                if label:
                    lines.append("  CH{:02d}: {}  # {}".format(channel, normalize_frequency(frequency), label))
                else:
                    lines.append("  CH{:02d}: {}".format(channel, normalize_frequency(frequency)))
        lines.append("")

    if not has_radio:
        return False

    filename = "{}.txt".format(safe_filename(group_name))
    with open(os.path.join(output_dir, filename), "w", encoding="ascii", errors="replace", newline="\n") as handle:
        handle.write("\n".join(lines).rstrip() + "\n")
    return True


def write_services_report(output_dir):
    lines = []
    lines.append("MISSION SERVICES")
    lines.append("================")
    lines.append("")
    lines.append("Carrier button plan:")
    lines.append("  Button 1  = Tower / Paddles / LSO")
    lines.append("  Button 2  = Departure")
    lines.append("  Button 3  = Strike")
    lines.append("  Button 4  = Red Crown")
    lines.append("  Button 15 = CCA Final A")
    lines.append("  Button 16 = Marshal / AIRBOSS")
    lines.append("  Button 17 = CCA Final B")
    lines.append("")
    for service_type, name, frequency, role, tacan, icls, link4 in MISSION_SERVICES:
        lines.append("{}: {}".format(service_type, name))
        lines.append("  FREQUENCY: {}".format(frequency))
        lines.append("  ROLE: {}".format(role))
        lines.append("  {}".format(tacan))
        lines.append("  {}".format(icls))
        lines.append("  {}".format(link4))
        buttons = CARRIER_BUTTONS.get(name)
        if buttons:
            lines.append("  BUTTONS:")
            for button, button_frequency, button_role in buttons:
                lines.append("    Button {:>2}: {} - {}".format(button, button_frequency, button_role))
        lines.append("")

    filename = os.path.join(output_dir, "mission_services.txt")
    with open(filename, "w", encoding="ascii", errors="replace", newline="\n") as handle:
        handle.write("\n".join(lines).rstrip() + "\n")


def main():
    parser = argparse.ArgumentParser(description="Export DCS radio presets from a .miz mission to ASCII text files.")
    parser.add_argument("--miz", default=os.path.join(os.path.dirname(__file__), MISSION_FILE))
    parser.add_argument("--output", default=os.path.join(os.path.dirname(__file__), "radio_presets"))
    args = parser.parse_args()

    os.makedirs(args.output, exist_ok=True)
    mission_text = load_mission_text(args.miz)
    groups = list(iter_air_groups(mission_text))
    common_labels = collect_common_frequency_labels(groups)

    written = 0
    scanned = 0
    for category, group_block in groups:
        scanned += 1
        if write_group_report(args.output, category, group_block, common_labels):
            written += 1
    write_services_report(args.output)

    print("Scanned air groups: {}".format(scanned))
    print("Wrote preset files: {}".format(written))
    print("Wrote services file: mission_services.txt")
    print("Output directory: {}".format(args.output))


if __name__ == "__main__":
    main()
