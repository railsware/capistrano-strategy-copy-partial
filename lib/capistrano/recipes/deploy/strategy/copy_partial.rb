require 'capistrano/recipes/deploy/strategy/copy'
require 'tempfile'  # Dir.tmpdir

class Capistrano::Deploy::Strategy::CopyPartial < Capistrano::Deploy::Strategy::Copy

  #
  #   set :copy_partial, 'subdir/of/project'
  #
  def deploy!
    if copy_cache
      if File.exists?(copy_cache)
        logger.debug "refreshing local cache to revision #{revision} at #{copy_cache}"
        system(source.sync(revision, copy_cache))
      else
        logger.debug "preparing local cache at #{copy_cache}"
        system(source.checkout(revision, copy_cache))
      end

      logger.debug "copying cache to deployment staging area #{destination}"
      Dir.chdir(copy_cache) do
        FileUtils.mkdir_p(destination)
        queue = Dir.glob("*", File::FNM_DOTMATCH)
        while queue.any?
          item = queue.shift
          name = File.basename(item)

          next if name == "." || name == ".."
          next if copy_exclude.any? { |pattern| File.fnmatch(pattern, item) }

          if File.symlink?(item)
            FileUtils.ln_s(File.readlink(File.join(copy_cache, item)), File.join(destination, item))
          elsif File.directory?(item)
            queue += Dir.glob("#{item}/*", File::FNM_DOTMATCH)
            FileUtils.mkdir(File.join(destination, item))
          else
            FileUtils.ln(File.join(copy_cache, item), File.join(destination, item))
          end
        end
      end
    else
      logger.debug "getting (via #{copy_strategy}) revision #{revision} to #{destination}"
      system(command)

      if copy_exclude.any?
        logger.debug "processing exclusions..."
        if copy_exclude.any?
          copy_exclude.each do |pattern| 
            delete_list = Dir.glob(File.join(destination, pattern), File::FNM_DOTMATCH)
            # avoid the /.. trap that deletes the parent directories
            delete_list.delete_if { |dir| dir =~ /\/\.\.$/ }
            FileUtils.rm_rf(delete_list.compact)
          end
        end
      end
    end

    File.open(File.join(destination_partial, "REVISION"), "w") { |f| f.puts(revision) }

    logger.trace "compressing #{destination_partial} to #{filename}"
    Dir.chdir(copy_dir) { system(compress(File.basename(destination), File.basename(filename), copy_partial).join(" ")) }

    upload(filename, remote_filename)
    if compression.partial_command && !copy_partial.empty?
      run "cd #{configuration[:releases_path]} && mkdir #{File.basename(destination)} && cd #{File.basename(destination)} && #{decompress(remote_filename).join(" ")} && rm #{remote_filename}"
    else
      run "cd #{configuration[:releases_path]} && #{decompress(remote_filename).join(" ")} && rm #{remote_filename}"
    end
  ensure
    FileUtils.rm filename rescue nil
    FileUtils.rm_rf destination rescue nil
  end

private

  def copy_partial
    @copy_partial ||= configuration.fetch(:copy_partial, '')
  end

  def destination_partial
    @destination_partial ||= File.join(destination, copy_partial)
  end

  # A struct for representing the specifics of a compression type.
  # Commands are arrays, where the first element is the utility to be
  # used to perform the compression or decompression.
  Compression = Struct.new(:extension, :compress_command, :decompress_command, :partial_command)
  
  # The compression method to use, defaults to :gzip.
  def compression
    type = configuration[:copy_compression] || :gzip
    case type
    when :gzip, :gz   then Compression.new("tar.gz",  %w(tar czf), %w(tar xzf), "-C")
    when :bzip2, :bz2 then Compression.new("tar.bz2", %w(tar cjf), %w(tar xjf), "-C")
    when :zip         then Compression.new("zip",     %w(zip -qr), %w(unzip -q), nil)
    else raise ArgumentError, "invalid compression type #{type.inspect}"
    end
  end
  
  # Returns the command necessary to compress the given directory
  # into the given file.
  def compress(directory, file, partial_dir='')
    if compression.partial_command && !partial_dir.empty?
      compression.compress_command + [file, compression.partial_command, "#{directory}/#{partial_dir}", './']
    else
      compression.compress_command + [file, directory]
    end
  end

  # Returns the command necessary to decompress the given file,
  # relative to the current working directory. It must also
  # preserve the directory structure in the file.
  def decompress(file)
      compression.decompress_command + [file]
  end
    
end
