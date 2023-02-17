import re
import argparse
from contextlib import suppress
import json


reg_cache = {
    re.compile(r"^\[\s*end\s*=\s*([0-9A-Fa-f]+|exit|s?goal)\s*]"): [0, 1],
    re.compile(r"^\[ ]"): [0],
    re.compile(r"^\[\s*br\s*]"): [0],
    re.compile(r"^\[\s*wait\s*]"): [0],
    re.compile(r"^\[\s*wait\s*=\s*(\d+)\s*]"): [0, 1],
    re.compile(r"^\[\s*(?:font\s+colou?r\s*=\s*1|/font\s+colou?r)\s*]"): [0],
    re.compile(r"^\[\s*font\s+colou?r\s*=\s*2\s*]"): [0],
    re.compile(r"^\[\s*font\s+colou?r\s*=\s*3\s*]"): [0],
    re.compile(r"^\[\s*pad\s+left\s*=\s*(\d+)\s*]"): [0, 1],
    re.compile(r"^\[\s*pad\s+right\s*=\s*(\d+)\s*]"): [0, 1],
    re.compile(r"^\[\s*pad\s*=\s*(\d+)\s*,\s*(\d+)\s*]"): [0, 1, 2],
    re.compile(r"^\[\s*music\s*=\s*([0-9a-fA-F]+)\s*]"): [0, 1],
    re.compile(r"^\[\s*erase\s*]"): [0],
    re.compile(r"^\[\s*/?topic\s*]"): [0],
    re.compile(r"^\[\s*sprite\s*=\s*([0-9A-Fa-f]+)\s*]"): [0, 1],
    re.compile(r"^\[\s*sprite\s*=\s*erase\s*]"): [0],
    re.compile(r"^\[\s*branch2?\s*=\s*(.+)\s*]"): [0, 1],
    re.compile(r"^\[\s*jump\s*=\s*(.+)\s*]"): [0, 1],
    re.compile(r"^\[\s*skip\s*=\s*(.+)\s*]"): [0, 1],
    re.compile(r"^\[\s*music2\s*=\s*([0-9a-fA-F]+)\s*]"): [0, 1],
    re.compile(r"^\[\s*space\s*width\s*=\s*([0-9]+)\s*]"): [0, 1],
    re.compile(r"^\[\s*switch\s*=\s*(on)\s*]"): [0],
    re.compile(r"^\[\s*switch\s*=\s*(off)\s*]"): [0],
    re.compile(r"^\[\s*switch\s*=\s*(toggle)\s*]"): [0],
    re.compile(r"^\[\s*compare\s*=\s*([0-9A-Fa-f]+)\s*,\s*(equal|not\s+equal|greater|less)\s*,\s*([0-9A-Fa-f]+)\s*,\s*(.+)\s*]"): [0, 1, 2, 3, 4],
    re.compile(r"^\[\s*sfx\s*1DF9\s*=\s*([0-9a-fA-F]+)\s*]"): [0, 1],
    re.compile(r"^\[\s*sfx\s*1DFC\s*=\s*([0-9a-fA-F]+)\s*]"): [0, 1],
    re.compile(r"^\[\s*exani\s*manual\s*=\s*((slot)?\s*([0-9a-fA-F]+))\s*,\s*((frame)?\s*([0-9a-fA-F]+))\s*]"): [0, 1, 3, 4, 6],
    re.compile(r"^\[\s*exani\s*custom\s*=\s*((slot)?\s*([0-9a-fA-F]+))\s*,\s*(enable|disable)\s*]"): [0, 1, 3, 4],
    re.compile(r"^\[\s*exani\s*one\s*shot\s*=\s*((slot)?\s*([0-9a-fA-F]+))\s*,\s*(enable|disable)\s*]"): [0, 1, 3, 4],
    re.compile(r"^\[\s*sfx\s*echo\s*=\s*on\s*]"): [0],
    re.compile(r"^\[\s*sfx\s*echo\s*=\s*off\s*]"): [0],
    re.compile(r"^\[\s*/?asm\s*=\s*once\s*]"): [0],
    re.compile(r"^\[\s*/?asm\s*=\s*always\s*]"): [0],
    re.compile(r"^\[\s*/?asm\s*=\s*stop\s*]"): [0],
}


class BaseVWFException(Exception):
    def __init__(self, errortype, *, message, **kwargs):
        self.message = message
        self.errortype = errortype
        self.others = kwargs

    def __repr__(self):
        return f'{self.errortype}\n{self.message}\n' + \
               '\n'.join([f'{v.capitalize()}: {k}' for v, k in self.others.items()])

    def __str__(self):
        return self.__repr__()


def define(definitions):
    print("Creating definitions...")
    def_path = definitions
    try:
        with open(def_path, "r") as f:
            content = f.read()
    except Exception as e:
        raise BaseVWFException('File reading error', message=f'Couldn\'t open {def_path}.', cause=str(e))

    content = re.sub(r"\s+", r"", content)

    i = 0
    while content and i <= 0x7F:
        tag = re.search(r"^(\[[^\[\]]+?])", content)
        tag2 = re.search(r"^([^\[\]])", content)
        if tag:
            content = re.sub(r"^(\[[^\[\]]+?])", r"", content)
            current_def = tag.group()
            result = get_tag(current_def)
            if current_def in result:
                raise BaseVWFException('Tag defining error',
                                       message=f"{str(current_def)} is a duplicate of a reserved tag",
                                       tag=result[result.index(current_def)],
                                       near=f"tag number 0x{(i - 1):02X}" if i > 0 else "the start of the file")
            else:
                definition[current_def] = i
        elif tag2:
            content = re.sub(r"^([^\[\]])", r"", content)
            current_def = tag2.group()
            definition[current_def] = i
        else:
            invalid_tag = content[:2]
            if invalid_tag == '[]':
                message = 'Tag is empty'
            elif invalid_tag[0] == '[':
                invalid_tag += '\u2026'
                message = 'Tag is unclosed'
            else:
                raise BaseVWFException('Tag defining error', message='Invalid tag')
            raise BaseVWFException('Tag defining error', message=message, tag=invalid_tag.replace('\n', ''))
        i += 1

    print("Finished creating definitions.\n")


def convert(convert_path):
    print("Converting dialogues...")
    try:
        with open(convert_path, "r") as f:
            content = f.readlines()
    except Exception as e:
        raise BaseVWFException('File reading error', message=f'Couldn\'t open {convert_path}.', cause=str(e))

    for x in range(len(content)):
        line = content[x]
        line_ = re.sub(r"//.*", r"", line)
        line_ = re.sub(r"^\s+|\s+$", r"", line_)
        if line is None:
            continue
        current_file = re.search(r"^([0-9A-Fa-f]+)\s+(.+)$", line_)
        if current_file and current_file.group():
            convert_txt(current_file.group(1), current_file.group(2))
        else:
            print(f"Line {str(x)}: Invalid information, {line_}")
    print("Finished converting dialogues.\n")


def convert_txt(msg_number, msg_path):
    try:
        msg_num = int(msg_number, 16)
    except ValueError:
        raise BaseVWFException('Conversion error', message=f"{msg_number} isn't a valid number!")

    if msg_num >= 0x100:
        raise BaseVWFException('Conversion error', message=f"The specified number is too high: 0x{msg_num:X}")

    try:
        with open("msg/" + msg_path, "r") as f:
            content = f.read()
    except Exception as e:
        raise BaseVWFException('File reading error', message=f'Couldn\'t open {msg_path}.', cause=str(e))

    content = re.sub(r"//.*", r"", content)  # comments
    content = re.sub(r"^\s+|\s+$", r"", content)  # leading or ending spaces
    content = re.sub(r"[\r\t\f]+", r"", content)  # line breaks

    original_content = content

    global bin_data, cur_num, num_used, asm_data
    data = []
    data_2 = []
    labels = {}
    for pass_ in range(2):
        data = []
        data_2 = []
        space = [-1]
        topic = 0
        content = original_content
        p = 0

        def parse_error(errortype, *, msg, **kwargs):
            current_pos = original_content.rindex(content)
            line = 1
            pos = 0
            while original_content.index('\n', pos) >= 0:
                pos = original_content.index('\n', pos)
                if pos >= current_pos:
                    break
                pos += 1
                line += 1
            return BaseVWFException(errortype, message=msg, **kwargs, line=line,
                                    near="\"" + content[:10].replace("\n", " ") + "\u2026\""
                                    if content else "end of file")

        while content:
            parse_tag = re.search(r"^(\[[^\[\]]+?])", content)
            parse_space = re.search(r"^\s+", content)
            parse_tag2 = re.search(r"^([^\[\]])", content)
            if parse_tag:
                content = re.sub(r"^(\[[^\[\]]+?])", r"", content)
                string = parse_tag.group()
                p += 1
            elif parse_space:
                content = re.sub(r"^\s+", r"", content)
                if space[0] >= 0:
                    space[0] = 1
                continue
            elif parse_tag2:
                content = re.sub(r"^([^\[\]])", r"", content)
                string = parse_tag2.group()
                p += 1
            else:
                invalid_tag = content[:2]
                if invalid_tag == '[]':
                    message = 'Tag is empty'
                elif invalid_tag[0] == '[':
                    invalid_tag += '\u2026'
                    message = 'Tag is unclosed'
                else:
                    raise parse_error('Conversion error', msg='Invalid tag')
                raise parse_error('Conversion error', msg=message, tag=invalid_tag.replace('\n', ''))
            get_def = definition.get(string)
            j = 1 if get_def is not None else 0
            command = get_tag(string)

            if j == 1:
                if space[0] > 0:
                    data.append(0x81)
                    data_2.append("[ ]")
                data.append(get_def)
                data_2.append(string)
                space[0] = 0

            elif command[0]:
                if command[0] & 0x80:  # ?
                    data.append(command[0])
                    data_2.append(command[1])

                if command[0] == 0x01:  # label
                    labels[command[2]] = len(data)

                elif command[0] == 0x80:  # end
                    space[0] = -1
                    parse_command_1 = re.search(r"^exit$", command[2])
                    parse_command_2 = re.search(r"^goal$", command[2])
                    parse_command_3 = re.search(r"^sgoal$", command[2])
                    data_2.append(command[2])
                    if parse_command_1:
                        data.append(0x20)
                    elif parse_command_2:
                        data.append(0x21)
                    elif parse_command_3:
                        data.append(0x22)
                    else:
                        cur_data = int(command[2], 16)
                        if cur_data < 0x20:
                            data.append(cur_data)
                        else:
                            raise parse_error('Out of range error',
                                              msg="The specified number in [end=*] is too high.",
                                              number=f'0x{cur_data:X}')

                elif command[0] == 0x82:  # line break
                    space[0] = -1

                elif command[0] == 0x84:  # wait timer
                    cur_data = int(command[2])
                    if cur_data < 0x100:
                        data.append(cur_data)
                        data_2.append(command[2])
                    else:
                        raise parse_error('Out of range error',
                                          msg="The specified number in [wait=*] is too high.",
                                          number=f'0x{cur_data:X}')

                elif command[0] == 0x88:  # pad left
                    cur_data = int(command[2])
                    if cur_data < 0x100:
                        data.append(cur_data)
                        data_2.append(command[2])
                    else:
                        raise parse_error('Out of range error',
                                          msg="The specified number in [pad left=*] is too high.",
                                          number=f'0x{cur_data:X}')

                elif command[0] == 0x89:  # pad right
                    cur_data = int(command[2])
                    if cur_data < 0x100:
                        data.append(cur_data)
                        data_2.append(command[2])
                    else:
                        raise parse_error('Out of range error',
                                          msg="The specified number in [pad right=*] is too high.",
                                          number=f'0x{cur_data:X}')

                elif command[0] == 0x8A:  # pad
                    cur_data_1 = int(command[2])
                    cur_data_2 = int(command[3])
                    data_2.append(command[2])
                    data_2.append(command[3])
                    if cur_data_1 < 0x100 and cur_data_2 < 0x100:
                        data.append(cur_data_1)
                        data.append(cur_data_2)
                    else:
                        raise parse_error('Out of range error',
                                          msg="One of the numbers in [pad=*,*] is too high.",
                                          number=f'0x{cur_data_1:X} or 0x{cur_data_2:X}')

                elif command[0] == 0x8B:  # music
                    cur_data = int(command[2], 16)
                    if cur_data < 0x100:
                        data.append(cur_data)
                        data_2.append(command[2])
                    else:
                        raise parse_error('Out of range error',
                                          msg="The specified number in [music=*] is too high.",
                                          number=f'0x{cur_data:X}')

                elif command[0] == 0x8C:  # erase
                    space[0] = -1

                elif command[0] == 0x8D:  # topic
                    topic = (topic + 1) & 1
                    if topic:
                        space.insert(0, -1)
                    else:
                        space.pop(0)


                elif command[0] == 0x8E:  # sprite
                    loop = int(command[2])
                    data_2.append(command[2])
                    if loop == 0 or loop >= 0x7F:
                        raise parse_error('Out of range error',
                                          msg="The specified number in [sprite=*] is not in the range 1-7F.",
                                          number=f'0x{loop:X}')
                    data.append(loop)
                    sprite_data = re.search(r"^\s*((?:.|\s)*?)\s*\[\s*/sprite\s*]", content)
                    content = re.sub(r"^\s*((?:.|\s)*?)\s*\[\s*/sprite\s*]", r"", content)
                    if sprite_data:
                        sprite = sprite_data.group(1)
                        sprite = re.sub(r"\s+", r"", sprite)
                        while sprite:
                            sprite_tile = re.search(
                                r"^\(([0-9A-Fa-f]+),([0-9A-Fa-f]+),([0-9A-Fa-f]+),([0-9A-Fa-f]+),(big|small)\)", sprite)
                            sprite = re.sub(
                                r"^\(([0-9A-Fa-f]+),([0-9A-Fa-f]+),([0-9A-Fa-f]+),([0-9A-Fa-f]+),(big|small)\)", r"",
                                sprite)

                            if sprite_tile:
                                data.append(int(sprite_tile.group(1), 16))
                                data.append(int(sprite_tile.group(2), 16))
                                data.append(int(sprite_tile.group(3), 16))
                                if "big" in sprite_tile.group(5):
                                    data.append((int(sprite_tile.group(4), 16) & 0xCF) | 0x20)
                                else:
                                    data.append((int(sprite_tile.group(4), 16) & 0xCF))
                                data_2.append(sprite_tile.group(1))
                                data_2.append(sprite_tile.group(2))
                                data_2.append(sprite_tile.group(3))
                                data_2.append(sprite_tile.group(4) + " " + sprite_tile.group(5))
                                loop = loop - 1
                            else:
                                raise parse_error('Invalid attribute error',
                                                  msg="Invalid attributes in [sprite=*,*][/sprite]",
                                                  attribute=sprite_tile)
                        if loop:
                            raise parse_error('Conversion error',
                                              msg="The number of attributes in [sprite=*,*][/sprite] not "
                                                  "matched to the loop number")
                    else:
                        raise parse_error('Unclosed tag error', msg="Unclosed [sprite] tag found.")
                elif command[0] == 0x90:
                    space[0] = -1
                    branches = command[2].split(",")
                    data_2.append(command[2])
                    nums = len(branches)
                    if nums < 2 or 5 < nums:
                        raise parse_error('Out of range error',
                                          msg="The number of labels in [branch=*] is not in range 2-5.",
                                          number=nums)
                    if pass_ == 0:
                        data.append(0x00)
                        for k in range(nums):
                            data.append(0x00)
                            data.append(0x00)
                            data_2.append(branches[k])
                            data_2.append(branches[k])
                    else:
                        branch_data = re.search(r"^\[\s*branch2", command[1])
                        if branch_data:
                            data.append(nums | 0x80)
                        else:
                            data.append(nums)
                        for x in range(len(branches)):
                            branch_data = re.sub(r"^\s+|\s+$", r"", command[1])
                            if branch_data:
                                pass
                            else:
                                raise parse_error('Empty label specified error',
                                                  msg="The empty label is specified in [branch=*].",
                                                  branch=command[1])

                            try:
                                branch_data_ = labels[branches[x]]
                                data.append(branch_data_ & 0xFF)
                                data.append(branch_data_ >> 8)
                                data_2.append(branches[x])
                                data_2.append(branches[x])
                            except KeyError:
                                raise parse_error('Label not defined error',
                                                  msg="The label in [branch=*] not defined yet.",
                                                  label=branches[x])

                elif command[0] == 0x91:  # jump
                    space[0] = -1
                    if pass_ == 0:
                        data.append(0x00)
                        data.append(0x00)
                        data_2.append(command[2])
                        data_2.append(command[2])
                    else:
                        try:
                            jump_data = labels[command[2]]
                            data.append(jump_data & 0xFF)
                            data.append(jump_data >> 8)
                            data_2.append(command[2])
                            data_2.append(command[2])
                        except KeyError:
                            raise parse_error('Label not defined error',
                                              msg="The label in [jump=*] not defined yet.",
                                              label=command[2])

                elif command[0] == 0x92:  # skip
                    if pass_ == 0:
                        data.append(0x00)
                        data.append(0x00)
                        data_2.append(command[2])
                        data_2.append(command[2])
                    else:
                        try:
                            skip_data = labels[command[2]]
                            data.append(skip_data & 0xFF)
                            data.append(skip_data >> 8)
                            data_2.append(command[2])
                            data_2.append(command[2])
                        except KeyError:
                            raise parse_error('Label not defined error',
                                              msg="The label in [skip=*] not defined yet.",
                                              label=command[2])

                elif command[0] == 0x93:  # music without sample upload
                    cur_data = int(command[2], 16)
                    data_2.append(command[2])
                    if cur_data < 0x100:
                        data.append(cur_data)
                    else:
                        raise parse_error('Out of range error',
                                          msg="The specified number in [music2=*] is too high.",
                                          number=f'0x{cur_data:X}')

                elif command[0] == 0x94:  # space width
                    cur_data = int(command[2])
                    if cur_data < 0x100:
                        data.append(cur_data)
                        data_2.append(command[2])
                    else:
                        raise parse_error('Out of range error',
                                          msg="The specified number in [space width=*] is too high.",
                                          number=f'0x{cur_data:X}')

                elif command[0] == 0x98:  # RAM/ROM compare
                    space[0] = -1
                    possibilities = command[5].split(",")
                    nums = len(possibilities)
                    if nums != 2:
                        raise parse_error('Out of range error',
                                          msg="The number of labels in [compare=*,*,*,*,*] is not 2.",
                                          number=nums)
                    data_2.append(command[2])
                    data_2.append(command[2])
                    data_2.append(command[2])
                    data_2.append(command[4])
                    data_2.append(command[3])
                    if pass_ == 0:
                        data.append(0x00)
                        data.append(0x00)
                        data.append(0x00)
                        data.append(0x00)
                        data.append(0x00)
                        for k in range(nums):
                            data.append(0x00)
                            data.append(0x00)
                            data_2.append(possibilities[k])
                            data_2.append(possibilities[k])
                    else:
                        current_address = int(command[2], 16)
                        current_compare = int(command[4], 16) 
                        data.append(current_address & 0xFF)
                        data.append((current_address >> 8) & 0xFF)
                        data.append((current_address >> 16) & 0xFF)
                        data.append(current_compare & 0xFF)
                        parse_command_1 = re.search(r"^equal$", command[3])
                        parse_command_2 = re.search(r"^not\s+equal$", command[3])
                        parse_command_3 = re.search(r"^greater$", command[3])
                        parse_command_4 = re.search(r"^less$", command[3])
                        if parse_command_1:
                            data.append(0x00)
                        elif parse_command_2:
                            data.append(0x01)
                        elif parse_command_3:
                            data.append(0x02)
                        elif parse_command_4:
                            data.append(0x03)
                        else:
                            raise parse_error('Invalid argument specified error',
                                            msg="The invalid argument is specified in [compare=*,*,*,*,*].",
                                            branch=command[3])
                        for x in range(len(possibilities)):
                            possibilities_data = re.sub(r"^\s+|\s+$", r"", command[1])
                            if possibilities_data:
                                pass
                            else:
                                raise parse_error('Empty label specified error',
                                                  msg="The empty label is specified in [compare=*,*,*,*,*].",
                                                  branch=command[1])

                            try:
                                data.append(labels[possibilities[x]] & 0xFF)
                                data.append(labels[possibilities[x]] >> 8)
                                data_2.append(possibilities[x])
                                data_2.append(possibilities[x])
                            except KeyError:
                                raise parse_error('Label not defined error',
                                                  msg="The label in [compare=*,*,*,*,*] not defined yet.",
                                                  label=possibilities[x])

                elif command[0] == 0x99:  # sfx playback
                    cur_data = int(command[2], 16)
                    data_2.append(command[2])
                    if cur_data < 0x100:
                        data.append(cur_data)
                    else:
                        raise parse_error('Out of range error',
                                          msg="The specified number in [sfx 1DF9=*] is too high.",
                                          number=f'0x{cur_data:X}')
                elif command[0] == 0x9A:  # sfx playback
                    cur_data = int(command[2], 16)
                    data_2.append(command[2])
                    if cur_data < 0x100:
                        data.append(cur_data)
                    else:
                        raise parse_error('Out of range error',
                                          msg="The specified number in [sfx 1DFC=*] is too high.",
                                          number=f'0x{cur_data:X}')

                elif command[0] == 0x9B:  # exanimation manual
                    cur_data = int(command[3], 16)
                    if cur_data < 0x10:
                        cur_frame = int(command[5],16)
                        if cur_frame < 0x100:
                                data.append(cur_data)
                                data.append(cur_frame)
                                data_2.append(command[2])
                                data_2.append(command[4])
                        else:
                            raise parse_error('Out of range error',
                                            msg="The specified frame number in [exani manual=*,*] is too high.",
                                            number=f'0x{cur_frame:X}')
                    else:
                        raise parse_error('Out of range error',
                                          msg="The specified slot number in [exani manual=*,*] is too high.",
                                          number=f'0x{cur_data:X}')

                elif command[0] == 0x9C:  # exanimation custom
                    cur_data = int(command[3], 16)
                    if cur_data < 0x10:
                        cur_setting = command[4].lower()
                        data_2.append(command[2]+" | "+command[4])
                        if cur_setting == "enable":
                                data.append(cur_data)
                        elif cur_setting == "disable":
                                data.append(cur_data | 0x80)
                        else:
                            raise parse_error('Invalid setting error',
                                            msg="The specified setting in [exani custom=*,*] is invalid.",
                                              label=command[4])
                    else:
                        raise parse_error('Out of range error',
                                          msg="The specified slot number in [exani custom=*,*] is too high.",
                                          number=f'0x{cur_data:X}')

                elif command[0] == 0x9D:  # exanimation one shot
                    cur_data = int(command[3], 16)
                    if cur_data < 0x20:
                        cur_setting = command[4].lower()
                        data_2.append(command[2]+" | "+command[4])
                        if cur_setting == "enable":
                                data.append(cur_data)
                        elif cur_setting == "disable":
                                data.append(cur_data | 0x80)
                        else:
                            raise parse_error('Invalid setting error',
                                            msg="The specified setting in [exani oneshot=*,*] is invalid.",
                                              label=command[4])
                    else:
                        raise parse_error('Out of range error',
                                          msg="The specified slot number in [exani oneshot=*,*] is too high.",
                                          number=f'0x{cur_data:X}')

                elif command[0] == 0xA0 or command[0] == 0xA1:  # execute asm
                    if len(asm_data) < 0x100:
                        cur_asm = re.search(r"^\s*((?:.|\s)*?)\s*\[\s*/asm\s*]", content)
                        content = re.sub(r"^\s*((?:.|\s)*?)\s*\[\s*/asm\s*]", r"", content)
                        data_2.append(len(asm_data))
                        if pass_ == 1:
                            data.append(len(asm_data))
                            asm_data.append(cur_asm.group(0).split("[/")[0])
                    else:
                        raise parse_error('Out of range error',
                                          msg="You already reached the maximum ASM routines allowed within a single sprite.",
                                          number=f'0x{len(asm_data):X}')

    cur_num += 1
    num_used[msg_number] = cur_num
    bin_data.append(data)
    print(f"'{msg_path}' conversion finished. Total size: 0x{len(data) + 1:02X} bytes")

    if debug:
        with open(f"parsed_{msg_number}.txt", "w") as f:
            for x in range(len(data)):
                index = f"{x:04X}"
                data_ = f"{int(data[x]):02X}"
                f.write(f"${index}: (0x{data_}) {data_2[x]}\n")


def create(output_path):
    global num_used, bin_data, asm_data
    print("Creating sprite...")
    with open(output_path, "w") as f:
        data_offsets = [0]
        total_bin_data = []
        w = 0
        for data in bin_data:
            data_offsets.append(len(data) + data_offsets[w])
            w += 1
            total_bin_data.extend(data)
        data_offsets.pop()
        with open('vwf_data.bin', 'wb') as b:
            b.write(bytes(total_bin_data))
        ptr = 'BinPtr:\n\tincbin "vwf_data.bin"\nDataPtr:'
        for i in range(len(num_used.keys())):
            if (i & 7) == 0:
                ptr += '\n\tdw'
            else:
                ptr += ", "
            with suppress(Exception):
                ptr += f' BinPtr+${data_offsets[i]:X}'
        w = 0
        asm = ''
        asm_ptr = 'RoutinePtr:'
        for asm_code in asm_data:
            if (w & 7) == 0:
                asm_ptr += '\n\tdw'
            else:
                asm_ptr += ", "
            asm_ptr += f' Routine{w:02X}'
            asm += f'Routine{w:02X}:\n{asm_code}\n'
            w += 1

        code = """
incsrc "vwf_defines.asm"

print "INIT ",pc
    PHX
    PHK
    PLA
    STA.l !VWF_DATA+$02
    STA.l !VWF_ASM_PTRS+$02
    REP #$30
    LDA !E4,x
    AND #$00F0
    LSR #3
    STA $00
    LDA !D8,x
    AND #$00F0
    ASL 
    ORA $00
    TAX
    LDA.l DataPtr,x
    STA.l !VWF_DATA
    LDA.w #RoutinePtr
    STA.l !VWF_ASM_PTRS
    SEP #$30
    PLX

print "MAIN ",pc
    RTL

"""

        f.write(f'{code}\n{ptr}\n{asm_ptr}\n{asm}')


def get_tag(orig_tag):
    r = re.search(r"^\[\s*label\s*=\s*(.+)\s*]", orig_tag)
    if r:
        return [0x01, r.group(0), r.group(1)]  # this was for some reason 0x01, so special case it is
    for h, pair in enumerate(reg_cache.items(), start=0x80):
        tag = pair[0]
        groups = pair[1]
        r = re.search(tag, orig_tag)
        if r:
            m_groups = [h]
            m_groups.extend([r.group(o) for o in groups])
            return m_groups
    return [0x00]


def generate_json(outputfile: str):
    json_filename = outputfile[:outputfile.rindex('.')] + '.json'
    json_boilerplate = {
        "$1656": {
            "Object Clipping": 0,
            "Can be jumped on": False,
            "Dies when jumped on": False,
            "Hop in/kick shell": False,
            "Disappears in cloud of smoke": False
        },
        "$1662": {
            "Sprite Clipping": 0,
            "Use shell as death frame": False,
            "Fall straight down when killed": False
        },
        "$166E": {
            "Use second graphics page": False,
            "Palette": 0,
            "Disable fireball killing": True,
            "Disable cape killing": True,
            "Disable water splash": False,
            "Don't interact with Layer 2": False
        },
        "$167A": {
            "Don't disable cliping when starkilled": True,
            "Invincible to star/cape/fire/bounce blk.": True,
            "Process when off screen": True,
            "Don't change into shell when stunned": False,
            "Can't be kicked like shell": False,
            "Process interaction with Mario every frame": True,
            "Gives power-up when eaten by yoshi": False,
            "Don't use default interaction with Mario": True
        },
        "$1686": {
            "Inedible": True,
            "Stay in Yoshi's mouth": False,
            "Weird ground behaviour": False,
            "Don't interact with other sprites": True,
            "Don't change direction if touched": True,
            "Don't turn into coin when goal passed": True,
            "Spawn a new sprite": False,
            "Don't interact with objects": True
        },
        "$190F": {
            "Make platform passable from below": False,
            "Don't erase when goal passed": True,
            "Can't be killed by sliding": True,
            "Takes 5 fireballs to kill": False,
            "Can be jumped on with upwards Y speed": False,
            "Death frame two tiles high": True,
            "Don't turn into a coin with silver POW": True,
            "Don't get stuck in walls (carryable sprites)": False
        },
        "AsmFile": outputfile,
        "ActLike": 54,
        "Type": 1,
        "Extra Property Byte 1": 0,
        "Extra Property Byte 2": 0,
        "Additional Byte Count (extra bit clear)": 0,
        "Additional Byte Count (extra bit set)": 0,
        "Map16": "",
        "Displays": [
            {
                "Description": "Loads VWF Cutscene Message Based on X, Y position",
                "ExtraBit": False,
                "Tiles": [
                    {
                        "X offset": 0,
                        "Y offset": 0,
                        "map16 tile": 267
                    }
                ],
                "X": 0,
                "Y": 0,
                "DisplayText": "",
                "UseText": False
            }
        ],
        "Collection": [
            {
                "Name": json_filename.replace('.json', '').replace('_', ' '),
                "ExtraBit": False,
                "Extra Property Byte 1": 0,
                "Extra Property Byte 2": 0,
                "Extra Property Byte 3": 0,
                "Extra Property Byte 4": 0
            }
        ]
    }
    with open(json_filename, 'w') as j:
        j.write(json.dumps(json_boilerplate, indent=4))
    print("Finished creating sprite files.")

print ("VWF Dialogues converter v2.0\n")

parser = argparse.ArgumentParser()
parser.add_argument("defines", help="File that contains the defines used to convert the scripts")
parser.add_argument("list", help="The list file containing the list of scripts you're converting")
parser.add_argument("output", help="The output file")
parser.add_argument("-d", "--debug", help="Produces debug files", action='store_true')

args = parser.parse_args()
debug = args.debug
if debug:
    print('Debug mode on\n')
bin_data = []
asm_data = []
num_used = {}
cur_num = 0
definition = {}
org_content = 0

try:
    define(args.defines)
    convert(args.list)
    if args.output.find('.') != -1:
        output = args.output[:args.output.rindex('.')] + '.asm'     # if output file is "*.xxx", replace with '*.asm'
    else:
        output = args.output + '.asm'                               # if output file doesn't have extension, add '.asm'
    create(output)
    generate_json(output)
except BaseVWFException as err:
    print(str(err))